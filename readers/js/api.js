import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";

const COOKIE = "reader_id";
const UUID = /^[0-9a-f-]{36}$/i;

export function getVoterId() {
  const m = document.cookie.match(new RegExp("(?:^|; )" + COOKIE + "=([^;]*)"));
  return m && UUID.test(m[1]) ? m[1] : null;
}

// Only call after the visitor has accepted the cookie.
export function acceptCookie() {
  const id = getVoterId() || crypto.randomUUID();
  document.cookie = COOKIE + "=" + id + "; max-age=31536000; path=/; SameSite=Lax" +
    (location.protocol === "https:" ? "; Secure" : "");
  return id;
}

async function rpc(fn, args) {
  const res = await fetch(SUPABASE_URL + "/rest/v1/rpc/" + fn, {
    method: "POST",
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: "Bearer " + SUPABASE_ANON_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(args || {}),
  });
  if (!res.ok) throw new Error("Something went wrong. Please try again.");
  return res.status === 204 ? null : res.json();
}

export const voteResults = () => rpc("vote_results");
export const myVote = (id) => rpc("my_vote", { p_voter: id });
export const castVote = (id, choice) => rpc("cast_vote", { p_voter: id, p_choice: choice });
export const listComments = () => rpc("list_comments");
export const addComment = (id, author, body) =>
  rpc("add_comment", { p_voter: id, p_author: author, p_body: body });

// Shows a cookie prompt unless already accepted or declined this session.
// Calls onChange(voterId|null) on load and whenever the choice changes.
export function initConsent(banner, onChange) {
  const id = getVoterId();
  if (id) { banner.hidden = true; return onChange(id); }
  onChange(null);
  if (sessionStorage.getItem("cookie_declined")) { banner.hidden = true; return; }
  banner.hidden = false;
  banner.querySelector("[data-accept]").onclick = () => {
    banner.hidden = true; onChange(acceptCookie());
  };
  banner.querySelector("[data-decline]").onclick = () => {
    sessionStorage.setItem("cookie_declined", "1"); banner.hidden = true;
  };
}
