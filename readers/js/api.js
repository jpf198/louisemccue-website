import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";

export const getCode = () => new URLSearchParams(location.search).get("k") || "";

async function rpc(fn, args) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: "Bearer " + SUPABASE_ANON_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(args),
  });
  if (!res.ok) throw new Error("Request failed. Is your QR link valid?");
  return res.status === 204 ? null : res.json();
}

export const castVote = (choice) => rpc("cast_vote", { p_code: getCode(), p_choice: choice });
export const voteResults = () => rpc("vote_results", { p_code: getCode() });
export const addComment = (author, body) =>
  rpc("add_comment", { p_code: getCode(), p_author: author, p_body: body });
export const listComments = () => rpc("list_comments", { p_code: getCode() });
