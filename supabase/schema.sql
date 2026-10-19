-- Run in the Supabase SQL editor (safe to re-run on a fresh project).
-- Direct table access is blocked by RLS; the site only calls the functions below.
-- Voters are identified by a random id stored in a cookie (only set after consent).

create table if not exists votes (
  id bigint generated always as identity primary key,
  voter_id uuid not null unique,
  choice text not null check (choice in ('did','didnt')),
  created_at timestamptz not null default now()
);

create table if not exists comments (
  id bigint generated always as identity primary key,
  voter_id uuid not null,
  author text not null check (char_length(author) between 1 and 60),
  body text not null check (char_length(body) between 1 and 1000),
  approved boolean not null default false, -- moderate by setting true in the dashboard
  created_at timestamptz not null default now()
);

alter table votes enable row level security;
alter table comments enable row level security;
-- no policies: anon cannot read or write directly.

create or replace function vote_results() returns json
language sql security definer set search_path = public as $$
  select json_build_object(
    'did', count(*) filter (where choice = 'did'),
    'didnt', count(*) filter (where choice = 'didnt')) from votes;
$$;

create or replace function my_vote(p_voter uuid) returns text
language sql security definer set search_path = public as $$
  select choice from votes where voter_id = p_voter;
$$;

create or replace function cast_vote(p_voter uuid, p_choice text) returns json
language plpgsql security definer set search_path = public as $$
begin
  insert into votes(voter_id, choice) values (p_voter, p_choice)
    on conflict (voter_id) do update set choice = excluded.choice;
  return vote_results();
end $$;

create or replace function add_comment(p_voter uuid, p_author text, p_body text) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into comments(voter_id, author, body) values (p_voter, trim(p_author), trim(p_body));
end $$;

create or replace function list_comments()
returns table (author text, body text, created_at timestamptz)
language sql security definer set search_path = public as $$
  select author, body, created_at from comments where approved
  order by created_at desc limit 200;
$$;

grant execute on function vote_results(), my_vote(uuid), cast_vote(uuid,text),
  add_comment(uuid,text,text), list_comments() to anon;
