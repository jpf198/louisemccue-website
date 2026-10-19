# Louise McCue

A static author website for Louise McCue.

- `index.html` — homepage
- `about.html` — about Louise
- `book.html` — debut book updates
- `styles.css` — shared responsive styles

To preview locally, run `python3 -m http.server` from this directory and open `http://localhost:8000`.

## Readers' vote & comments (Supabase)

Hidden pages at `/readers/vote.html` and `/readers/comments.html` are reached via the QR code/link
printed in the book. They are not linked from the site, are `noindex`, and are disallowed in `robots.txt`.
There is no per-visitor code: anyone with the link can view.

- Visitors see a cookie prompt. If they decline, they can only see the vote counts and approved comments.
- If they accept, a random `reader_id` cookie (1 year) is stored. It identifies them for voting (one vote each,
  changeable) and commenting, and they are not asked again.

Setup:
1. Create a free Supabase project and run `supabase/schema.sql` in the SQL editor.
2. Put the project URL and anon key in `readers/js/config.js` (both are public values).
3. Optionally run `supabase/seed.sql` for sample votes/comments (delete queries are in the file).
4. Moderate comments in the Table Editor: new comments have `approved = false`; set to `true` to publish.

RLS is enabled with no policies, so the browser can only use the functions in the schema. The cookie id
is client-generated, so this is deterrence against casual repeat voting, not strong protection.
