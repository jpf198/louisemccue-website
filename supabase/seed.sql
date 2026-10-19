-- Optional sample data. Run in the Supabase SQL editor AFTER schema.sql.
-- Seed rows use voter_ids starting 00000000-0000-0000-0000-... so they are easy to remove:
--   delete from votes    where voter_id::text like '00000000-0000-0000-0000-%';
--   delete from comments where voter_id::text like '00000000-0000-0000-0000-%';
-- Replace the placeholder text below with your own before going live.

insert into votes (voter_id, choice) values
  ('00000000-0000-0000-0000-000000000001', 'did'),
  ('00000000-0000-0000-0000-000000000002', 'did'),
  ('00000000-0000-0000-0000-000000000003', 'didnt')
on conflict (voter_id) do nothing;

insert into comments (voter_id, author, body, approved) values
  ('00000000-0000-0000-0000-000000000001', 'Sample reader', 'Sample comment: I am absolutely certain she did.', true),
  ('00000000-0000-0000-0000-000000000003', 'Another reader', 'Sample comment: no chance. Not Ruben.', true),
  ('00000000-0000-0000-0000-000000000002', 'Pending reader', 'Sample unapproved comment, hidden until approved = true.', false);
