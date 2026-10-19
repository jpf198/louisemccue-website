-- Run in the Supabase SQL editor. Direct table access is blocked by RLS;
-- the site only talks to the security-definer functions below.
create extension if not exists pgcrypto;

create table if not exists book_codes (
  code text primary key,
  note text,
  revoked boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists votes (
  id bigint generated always as identity primary key,
  code text not null references book_codes(code),
  choice text not null check (choice in ('did','didnt')),
  created_at timestamptz not null default now(),
  unique (code)
);

create table if not exists comments (
  id bigint generated always as identity primary key,
  code text not null references book_codes(code),
  author text not null check (char_length(author) between 1 and 60),
  body text not null check (char_length(body) between 1 and 1000),
  approved boolean not null default false, -- moderate by setting true in the dashboard
  created_at timestamptz not null default now()
);

alter table book_codes enable row level security;
alter table votes enable row level security;
alter table comments enable row level security;
-- no policies: anon/authenticated cannot read or write directly.

create or replace function valid_code(p_code text) returns boolean
language sql security definer set search_path = public as $$
  select exists (select 1 from book_codes where code = p_code and not revoked);
$$;

create or replace function cast_vote(p_code text, p_choice text) returns json
language plpgsql security definer set search_path = public as $$
begin
  if not valid_code(p_code) then raise exception 'invalid code'; end if;
  insert into votes(code, choice) values (p_code, p_choice)
    on conflict (code) do update set choice = excluded.choice;
  return vote_results(p_code);
end $$;

-- Results are only returned to holders of a valid code.
create or replace function vote_results(p_code text) returns json
language plpgsql security definer set search_path = public as $$
begin
  if not valid_code(p_code) then raise exception 'invalid code'; end if;
  return (select json_build_object(
    'did', count(*) filter (where choice = 'did'),
    'didnt', count(*) filter (where choice = 'didnt')) from votes);
end $$;

create or replace function add_comment(p_code text, p_author text, p_body text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not valid_code(p_code) then raise exception 'invalid code'; end if;
  insert into comments(code, author, body) values (p_code, trim(p_author), trim(p_body));
end $$;

create or replace function list_comments(p_code text)
returns table (author text, body text, created_at timestamptz)
language plpgsql security definer set search_path = public as $$
begin
  if not valid_code(p_code) then raise exception 'invalid code'; end if;
  return query select c.author, c.body, c.created_at from comments c
    where c.approved order by c.created_at desc limit 200;
end $$;

revoke all on function valid_code(text) from public, anon, authenticated;
grant execute on function cast_vote(text,text), vote_results(text),
  add_comment(text,text,text), list_comments(text) to anon;

-- Example codes (generate one per book/batch):
-- insert into book_codes(code, note) values (encode(gen_random_bytes(12),'hex'), 'batch 1');
