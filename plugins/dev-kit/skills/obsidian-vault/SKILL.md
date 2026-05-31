---
name: obsidian-vault
description: Maintain your Obsidian vault at <OBSIDIAN_VAULT_PATH>/. Every project gets the same standardized folder layout, lives under <Project Name>/, and stays current as work progresses. Trigger when the user says "Obsidian vault", "the vault", "update the vault", or asks for project status updates after work landed. Skill encodes the layout, the maintenance contract, the housekeeping rubric, and the human-AND-AI-readable format conventions.
license: Apache-2.0
category: documentation
---

# Obsidian Vault — Standard project layout + maintenance contract

> Single source of truth for project state. Updated continuously as work progresses. Human-readable AND AI-readable.

---

## 1. Where the vault lives

`<OBSIDIAN_VAULT_PATH>/`

Each project gets its own top-level folder named after the project (use the codename in use, e.g. `web-app`, `client-portal`, `cli-tool`, `data-pipeline`).

If macOS denies file writes (TCC), the user must add the calling process (Claude Code app, Terminal, iTerm2) to **System Settings → Privacy & Security → Full Disk Access**.

---

## 2. Standard layout per project

```
<Project Name>/
├── README.md                       ← index / landing. Always read this first.
├── 00 - Start Here.md              ← orientation for new readers (human & AI)
├── 01 - Current State.md           ← LIVE status: main HEAD, in-flight, just-shipped. Update on every wave/merge/decision.
├── 02 - Overview.md                ← what the project IS — business context, who, why, glossary
├── 03 - Architecture.md            ← deep tech: stack, file ownership, key patterns. Durable.
├── 04 - Roadmap.md                 ← what's next, priorities, dependencies, won't-do
├── 05 - Decisions Log.md           ← append-only: architectural + product decisions with rationale
├── 06 - Known Gotchas.md           ← landmines: things that bit us, hard-won lessons
├── 07 - Initiative History.md      ← what shipped, wave-by-wave, PR ledger
├── 08 - Audit Findings.md          ← (if applicable) prod-readiness audits + resolution
├── 09 - Integration Status.md      ← (if applicable) CMS / Social / API integration matrix
├── 10 - Glossary.md                ← project-specific terminology
├── Initiatives/                    ← per-initiative plans + deep dives
│   └── <Initiative Name>.md
├── Lessons Learned/                ← one file per lesson (YYYY-MM-DD - <topic>.md). See §4a.
│   └── YYYY-MM-DD - <lesson topic>.md
├── Daily Updates/                  ← date-stamped change logs (YYYY-MM-DD.md)
├── Orchestration Handoffs/         ← session-end snapshots for next Claude Code session
├── User Docs/                      ← human-facing usage docs (rendered as markdown)
├── AI Docs/                        ← AI-readable: prompts, system instructions, agent briefs, runbooks for AI
├── Tech Details/                   ← durable technical reference: schema, auth, queues, etc.
└── Attachments/                    ← images, diagrams, screenshots (Obsidian default)
```

**Rules for the layout:**
- `README.md` has no number prefix → sorts first in most file browsers
- Top-level notes use `00 -` through `99 -` prefix → sortable, ordered, scannable
- Folders use plain names (no number prefix) — cleaner in tree view
- Not every project needs every folder/note. Create only what's used; remove stale empty folders.
- If a project has only one initiative, `Initiatives/` may be skipped and content lives in numbered top-level notes
- Per-project deviation is fine when justified (write the deviation in `00 - Start Here.md`)

---

## 3. Format conventions

Every note has YAML frontmatter:

```yaml
---
project: <project-name-slug>
type: <state | overview | architecture | roadmap | decision | gotcha | history | audit | integrations | plan | daily-update | handoff | tech-ref | user-doc | ai-doc>
updated: 2026-MM-DD
tags: [optional]
---
```

Body uses:
- **Wikilinks** `[[Note Name]]` for cross-references (Obsidian renders these as clickable)
- **Tables** for status snapshots and matrices
- **Code fences** with language tag for code/config
- **Headers** in clear hierarchy (H1 for note title, H2 for sections, H3 for sub-sections)
- **Timestamps** in ISO format (`2026-05-13`)

**Tone:**
- Direct. No fluff. No marketing copy.
- Past tense for what happened. Present for what is. Future for what's planned.
- Surface trade-offs and known weaknesses, not just wins. Future-you (or future-Claude) needs to know what was deliberate vs accidental.

---

## 4. Maintenance contract — when to update

Update the vault as work progresses, not in batches. Specifically:

| Event | Update |
|---|---|
| Wave / merge cascade landed | `01 - Current State.md` + `07 - Initiative History.md` + `Daily Updates/YYYY-MM-DD.md` |
| Architectural decision made | `05 - Decisions Log.md` (append) |
| Audit / scan delivered | `08 - Audit Findings.md` |
| New gotcha discovered | `06 - Known Gotchas.md` (append) |
| Lesson learned (insight worth keeping — process, judgment call, what-we'd-do-different) | Create a NEW file in `Lessons Learned/` — see §4a |
| Roadmap change | `04 - Roadmap.md` |
| New initiative scoped | `Initiatives/<name>.md` + reference in `04 - Roadmap.md` |
| Session boundary (end of focused work block) | `Orchestration Handoffs/YYYY-MM-DD-<topic>.md` |
| Schema / API surface change | `Tech Details/<topic>.md` + reference in `03 - Architecture.md` |
| Initiative complete | Mark in `07 - Initiative History.md`, archive plan in `Initiatives/Completed/`, update `01 - Current State.md` |

**The user asks for an update / TLDR / status?** → Read `01 - Current State.md` first (it should be fresh). If it's stale, regenerate it from git + the issue tracker BEFORE answering — never serve a stale snapshot.

---

## 4a. Lessons Learned — rules

Lessons Learned is a **per-lesson, one-file-per-lesson** folder. It is NOT a single appended log.

**Rules:**

1. **One file per lesson.** Never combine multiple lessons into a single note. If two lessons feel like one, you have either (a) two notes, or (b) one note with the wrong scope — split until each file is one self-contained takeaway.
2. **File naming:** `YYYY-MM-DD - <short title>.md`
   - Date is when the lesson was *recognized*, not when the originating event happened.
   - Title is a 3–8 word phrase capturing the takeaway, not the incident. Good: `Always pin Stripe API version in webhooks.md`. Bad: `Stripe outage.md`.
3. **Frontmatter:**
   ```yaml
   ---
   project: <project-slug>
   type: lesson-learned
   date: YYYY-MM-DD
   tags: [optional — e.g. infra, billing, auth, ops, judgment]
   related: [optional — wikilinks to incidents / PRs / decisions]
   ---
   ```
4. **Body structure** (keep it tight — no walls of prose):
   - **Context** — 1–3 sentences. What was happening when this lesson surfaced.
   - **What happened** — the concrete event/decision/observation.
   - **Lesson** — the takeaway, stated as a rule or principle. One sentence preferred.
   - **How to apply** — when/where this rule kicks in for future work. Be specific enough that future-you (or future-Claude) can recognize the situation.
5. **Lesson vs Gotcha vs Decision** — they are distinct, do not duplicate:
   - **Gotcha** (`06 - Known Gotchas.md`) → a specific landmine in the *code or system*. "If you do X, Y breaks." Appended to the single notes file.
   - **Decision** (`05 - Decisions Log.md`) → a chosen path with rationale. Append-only log.
   - **Lesson Learned** (`Lessons Learned/<file>.md`) → a *judgment-level insight* — process, prioritization, communication, scope, what-we'd-do-different. Worth a standalone file because future-you should be able to find it by title alone.
6. **Cross-link**, don't duplicate. If a lesson came from an incident logged in `Daily Updates/`, link to it with `[[Daily Updates/YYYY-MM-DD]]` rather than repeating the incident narrative.
7. **Don't pre-stub.** A lesson file is created when a real lesson exists. An empty `Lessons Learned/` folder is fine; an empty file in it is noise.

---

## 5. Housekeeping — anti-stale rubric

When a Claude Code session starts work on a project, BEFORE doing anything else:

1. Read `01 - Current State.md`. Check `updated:` frontmatter.
2. Compare to git: `git log --oneline -1` on main vs the `main HEAD` field in the note.
3. If they don't match → snapshot is stale. Regenerate from authoritative sources (git log, gh pr list, Linear) and update the note BEFORE acting on it.
4. If `Daily Updates/` has no entry for today and meaningful work happens, create one.
5. Once a week (or at major-milestone boundaries), scan for:
   - Empty notes / placeholder folders → delete or fill
   - Notes referenced via `[[wikilink]]` that don't exist → create stub or remove the link
   - `04 - Roadmap.md` items still listed after they've shipped → move to `07 - Initiative History.md`
   - `Daily Updates/` files with no content beyond frontmatter → delete

**Never:**
- Let `01 - Current State.md` drift more than one wave behind reality
- Leave half-written notes (always finish a section before moving on, or mark `TODO:` explicitly)
- Duplicate state between notes (cross-link instead — `See [[03 - Architecture#Multi-tenancy]]`)
- Use AI-generated marketing copy (Jason will edit it out anyway)

---

## 6. Human-readable AND AI-readable

This vault is read by both Jason (Obsidian app) AND future Claude Code sessions.

**For Jason:** clean tables, scannable bullets, no walls of prose. Numbered prefix gets him to the right note in 2 clicks.

**For Claude (future sessions):**
- YAML frontmatter so semantic indexers can categorize notes
- Wikilinks so graph view + AI traversal both work
- `AI Docs/` folder holds notes specifically structured for AI consumption (prompt templates, agent system prompts, runbooks like "how to do X via this codebase's conventions")
- `Tech Details/` holds normalized facts (schema fields, route signatures, env var names) — fast lookup, no narration

When writing a note, ask: "If I'm a Claude Code session in 30 days with zero conversation context, can I pick this up and continue?" If the answer is no, add the missing context.

---

## 7. Triggering this skill

This skill should activate when the user:
- Says "Obsidian vault", "the vault", "update the vault"
- Asks for a "status update" or "TLDR" on a project AND there's an active vault for that project
- Asks "where are we at" / "where did we leave off"
- Mentions a project codename in context where state is being requested

When the user types a codename Claude doesn't recognize, default to checking `<OBSIDIAN_VAULT_PATH>/<Codename>/` and reading the README + Current State. If the folder doesn't exist, ask before creating one.

---

## 8. Bootstrapping a new project's vault

When a new project starts:

1. `mkdir -p "<OBSIDIAN_VAULT_PATH>/<Project Name>/"{Initiatives,"Lessons Learned","Daily Updates","Orchestration Handoffs","User Docs","AI Docs","Tech Details",Attachments}`
2. Create `README.md` with index pointing to other notes
3. Create `00 - Start Here.md` with one paragraph of context for a new reader
4. Create `01 - Current State.md` with the latest snapshot from git
5. Create `02 - Overview.md` with the elevator pitch + business context
6. Other numbered notes added as content arrives — not pre-created empty

Don't pre-stub everything. Empty notes are noise.

---

## 9. Migrating an existing willy-nilly project to this layout

1. Inventory existing files
2. Identify what corresponds to which standard slot
3. Move content into the right numbered note (don't recreate from scratch if good content exists)
4. Create missing standard folders
5. Add YAML frontmatter to existing notes that lack it
6. Add `_How this vault is maintained.md` only if the project has unusual deviations from this standard
7. Commit the migration with a note in `Daily Updates/YYYY-MM-DD.md`

---

## 10. Examples in the wild (in this vault)

- **Best examples to mirror:** `data-pipeline`, `client-portal`, `cli-tool`, `monitoring-service` — all use the numbered-prefix pattern cleanly
- **Most-evolved:** `web-app` — has the full top-level numbered set plus `Initiatives/` and `Daily Updates/`
- **Anti-pattern to avoid:** folders with only `Portfolio.md` and nothing else (AEO Check, AINode, Floq, etc.) — either expand or delete

---

## 11. What this skill is NOT

- Not a content-generator. The user writes the content; this skill enforces structure.
- Not a backup system. Use git or iCloud or Obsidian Sync for that.
- Not a project management tool. Linear handles that.
- Not a code-storage system. Code lives in git.

The vault is the **navigational layer + state-snapshot system + decision log** that connects all of those.

---

## Quick reference for Claude Code sessions

```
User says "update the Obsidian vault" or similar
  ↓
1. Identify the project (codename from context, or ask)
2. cd <OBSIDIAN_VAULT_PATH>/<Project>/
3. Read 01 - Current State.md (it's the source of truth)
4. Compare to git / gh pr list / Linear
5. If stale → regenerate. If fresh → confirm.
6. Update affected notes (Current State, Initiative History, Decisions Log, Daily Updates)
7. Use wikilinks for cross-references
8. Frontmatter on every new note
9. Confirm what changed when done
```
