---
name: followup-closet
description: Record and maintain a project's follow-ups and to-dos in Jason's central Obsidian "closet" so loose threads survive across sessions and can be pulled from one list. Use proactively whenever work leaves a deferred, blocked, descoped, or noticed-but-not-fixed item; when the user says "add a to-do/follow-up", "log this for later", "the closet", "things to follow up on", "remind me to"; and at the end of a wave, session, or orchestration. Orchestrators and workers both log here — for each completed-with-leftovers or blocked dispatch.
---

# Follow-Up Closet

One file holds every loose thread, grouped by project, so Jason pulls follow-ups from a single place. Logging one is **a single appended line** — keep it that light.

**Closet:** `<FOLLOWUP_FILE_PATH>`

## When to log (do it the moment it appears — don't wait to be asked)
- A task you deferred, descoped, or ran out of scope/time for
- Something broken or off you noticed but didn't fix
- A blocker, missing access/credential, or unresolved open question
- A "worth doing later, not now" idea
**Don't** log things you finished this session, or trivia.

## How to add one — the whole contract
1. Open the closet file.
2. Find the `## <Project>` heading for the project you're in (use the repo / vault-folder name). Missing? Create it, keeping the list roughly alphabetical. Cross-project / infra items go under `## _Workspace (cross-project)` at the bottom.
3. Append ONE line under that heading:
   ```
   - [ ] <imperative action> #followup/<category> (added YYYY-MM-DD) — <context or [[wikilink]]>
   ```
   Mark urgent/live-breakage with a leading `🔴`.
4. Save. That's it.

**Category** (nested tag — lets Jason slice the closet by type via the tag pane / `tag:#followup/<category>` search). Pick one:
`broken` (live breakage/outage) · `health` (health endpoints) · `monitoring` (observability/uptime) · `access` (creds/permissions) · `hygiene` (docs/vault/repo cleanup) · `decision` (needs a call) · `build` (feature work for later). Unsure? Use bare `#followup`.

## Rules
- **One checkbox per item.** Action-first, enough context that future-you needs no chat history.
- **Append-only on others' items.** Never reword or delete someone's open item; only add new ones, or check off (`- [x]`) ones you genuinely completed.
- **Real date.** Use today's actual date in `(added YYYY-MM-DD)` — never a guess.
- **Always tag `#followup/<category>`** (or bare `#followup`) — `tag:#followup` still matches all nested categories, so nothing is lost while gaining per-category views.
- **Vault unreachable** (remote host / no Mac vault)? Fall back to `FOLLOWUPS.md` at the project root, same format, and say so — don't silently drop the item.
- **Light by design.** This is a one-line append, not a ceremony. No status meetings, no sub-tasks unless the user asks.

## Example
```
## Acme API
- [ ] 🔴 Fix the login redirect loop on staging before Friday's demo #followup/broken (added 2026-01-15) — [[Acme API/README|Acme API]]
```

## Reading back
When the user asks "what's open for X" / "pull my follow-ups", read the closet and report the unchecked items under `## X` (and relevant `## _Workspace` ones). If `01 - Current State` exists for that project, reconcile — don't report items already shipped.
