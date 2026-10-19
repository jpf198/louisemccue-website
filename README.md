# Louise McCue

A static author website for Louise McCue.

- `index.html` — homepage
- `about.html` — about Louise
- `book.html` — debut book updates
- `styles.css` — shared responsive styles

To preview locally, run `python3 -m http.server` from this directory and open `http://localhost:8000`.

## Readers' vote & comments (Supabase)

Hidden pages at `/readers/vote.html` and `/readers/comments.html` are reached only via the QR code
printed in the book: `https://<site>/readers/vote.html?k=<CODE>`. They are not linked from the site,
are `noindex`, and are disallowed in `robots.txt`.

Setup:
1. Create a free Supabase project.
2. Run `supabase/schema.sql` in the SQL editor.
3. Put the project URL and anon key in `readers/js/config.js` (both are public values).
4. Insert codes: `insert into book_codes(code, note) values (encode(gen_random_bytes(12),'hex'), 'batch 1');`
   and print one in each QR URL. Each code has one vote (re-voting changes it). Set `revoked = true` to disable a leaked code.
5. Moderate comments in the Table Editor: new comments have `approved = false`; set it to `true` to publish.

Tables have RLS enabled with no policies, so the browser can only use the `cast_vote`, `vote_results`,
`add_comment` and `list_comments` functions, each of which checks the code. No environment variables are
needed, since the site is static.
