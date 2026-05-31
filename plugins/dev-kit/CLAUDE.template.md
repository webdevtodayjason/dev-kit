# Claude Instructions for <YOUR_NAME>

<!-- This is a fill-in template, NOT an auto-loaded file. Copy it to
     ~/.claude/CLAUDE.md (or a project ./CLAUDE.md), replace every <PLACEHOLDER>,
     and delete any section whose tooling you have not installed. It keeps the
     portable agent-operating conventions and strips all private specifics. -->

## Security
- API keys / secrets location: `<SECRETS_LOCATION>`  <!-- e.g. a .env file, ~/.secrets, or your password manager. Point here, do not paste values. -->
- **NEVER USE WITHOUT PERMISSION** — credentials exist at the location above; do not read or use them unless I explicitly ask.

---

## About Me (optional)

<!-- Optional. A few lines on your background and how technical you are, so the
     agent calibrates depth. Delete this section if you don't want it. Do NOT put
     financial goals, net worth, or private infra here. -->
- Experience level: <PLACEHOLDER>
- Calibrate explanations to: <PLACEHOLDER — e.g. "senior dev, skip the basics">

---

## My Environment / Resources

<!-- Describe YOUR machine(s) so the agent sizes solutions correctly and doesn't
     assume artificial limits. Keep it generic — no need to publish IPs or topology. -->
- Primary machine: <PLACEHOLDER — e.g. "MacBook Pro M3, 36GB RAM">
- Other compute (optional): <PLACEHOLDER>
- Resource assumption: <PLACEHOLDER — e.g. "treat this as a capable dev box; don't assume tight limits">

---

## How I Like Agents to Work

1. **Match my depth** — don't over-explain basics I already know.
2. **Value speed** — ship fast, iterate; prefer a working first pass over a perfect plan.
3. **Assume my real resources** — size solutions to the environment above.
4. **Business context** — <PLACEHOLDER — e.g. "much of this work serves clients; flag anything client-facing">.
5. **Prefer free / open-source** when quality is comparable.

<!-- Personal/financial goals and partner-specific notes were intentionally
     removed from this template — never put net-worth or retirement targets in a
     checked-in file. -->

---

## Current Projects

<!-- List your own active projects so the agent has context. One line each:
     name — description — stack. -->
- <PLACEHOLDER>

---

## Memory System (claude-mem)

<!-- Assumes the claude-mem plugin is installed. Install it, or delete this section. -->

claude-mem captures observations automatically. To avoid losing cross-session context:

1. **On every session start (including after `/clear` or compact)**: proactively search memory for the most recent session context BEFORE greeting me, so you know what was being worked on.
2. **Before re-reading files**: check memory first — past observations may already contain the analysis you need.
3. **Use the 3-layer workflow**: search → timeline → get_observations. Don't fetch full details without filtering first.
4. **Treat the session-start context index seriously**: scan it for relevant context before diving in.

---

## Follow-Up Closet

<!-- Set the path below to your own running follow-up list (any Markdown file).
     The `followup-closet` skill (shipped in dev-kit) automates this. -->

Loose threads — deferred tasks, things noticed-but-not-fixed, blockers, "do later"
ideas — go in one central file so they're never lost and can be pulled from a single
list: **`<FOLLOWUP_FILE_PATH>`** (grouped by project).

This is **expected, not optional**: any agent, in any project, logs its follow-ups
there as they surface — one appended checkbox line is the whole cost.

---

## Compaction Handoff

When summarizing this conversation for compaction (manual `/compact` or
auto-compact at the configured threshold), always include a `HANDOFF`
section with:

- **Branch:** current git branch
- **Last decision:** most recent meaningful decision made this segment
- **Next step:** immediate next action to take
- **Open questions:** anything blocked, ambiguous, or awaiting input

This survives compaction because CLAUDE.md re-injects afterward.

---

## Web Tooling (optional — only if you install an MCP for it)

<!-- This captures a useful PATTERN: prefer an installed web-tooling MCP over
     hand-rolled WebSearch/curl/Playwright. Install your own web-automation MCP and
     set the endpoint below, or delete this whole section if you have none. -->

If a web-automation MCP is installed (endpoint: `<WEB_MCP_ENDPOINT>`), prefer its
tools over hand-rolled alternatives:

| Need | Prefer the MCP tool | Avoid |
|---|---|---|
| Live web search | MCP search | raw WebSearch |
| Fetch a URL's content | MCP fetch | WebFetch, curl |
| Browser automation / multi-step web flow | MCP automation | hand-rolled Playwright |

- **2+ URLs**: use the MCP's batch create/status — don't loop individual fetches.
- **Retry caution**: if an automation call returns an error, the run may STILL be
  executing on the provider's side. Do NOT blind-retry (it can double-spend) — first
  check the run's actual status, retry only if it is genuinely terminal-failed.

---

*Template shipped with the `dev-kit` plugin. Replace all <PLACEHOLDER> tokens and
remove sections for tooling you have not installed.*
