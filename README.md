# dev-kit — a portable Claude Code workflow

A one-install Claude Code marketplace plugin that sets up a complete development
workflow: skills, slash commands, sub-agents, output styles, optional security
hooks, and a fill-in `CLAUDE.md` template.

**Ships zero credentials.** No API keys, no private infrastructure, no machine-specific
paths. You bring your own MCP keys and choose your own permission posture.

---

## ⚡ Quick setup — paste this to your agent

Hand this to your Claude Code session (or any coding / cloud agent) and it will set
everything up, interviewing you only where it needs your specifics:

```text
You're setting up the "dev-kit" Claude Code marketplace plugin on my machine.
Work through these steps in order, asking me only when you genuinely need input:

1. INSTALL: run `/plugin marketplace add webdevtodayjason/dev-kit`, then
   `/plugin install dev-kit@jason`, then tell me to restart Claude Code so the
   skills, commands, agents, and the context7 MCP register.

2. PREREQS (report what's missing; don't install anything without asking first):
   - node / npx  -> needed for the keyless context7 docs MCP
   - uv          -> needed only for the optional damage-control security hooks
   - gh CLI (authenticated) -> needed for the review/commit workflows and find-docs

3. CLAUDE.md: copy `plugins/dev-kit/CLAUDE.template.md` to `~/.claude/CLAUDE.md`
   (or this project's `./CLAUDE.md`). Then interview me briefly to fill every
   <PLACEHOLDER> (my name, machine/resources, where my secrets live, current
   projects, my follow-up-list file path). Delete any section whose tooling I
   have not installed.

4. CONSERVATIVE PERMISSIONS: in `~/.claude/settings.local.json`, add a deny list
   for catastrophic commands (rm -rf /*, rm -rf ~/*, sudo rm -rf, mkfs,
   dd ... of=/dev/*) and an ask list (git push --force, git reset --hard).
   Do NOT enable bypassPermissions, CLAUDE_AUTONOMY, or any skip-prompt flags.

5. MCP CREDENTIALS (mine only — never reuse anyone else's): context7 works
   keyless out of the box. If I use Linear or ghost.build, walk me through adding
   them with MY own key / login.

6. OPTIONAL SECURITY HOOKS: if I want the damage-control PreToolUse firewall,
   confirm uv is installed, then run the damage-control skill's install cookbook.

7. VERIFY: run `/context-audit` and confirm the new skills and commands appear.

Never write secrets into a committed file. Confirm each step's result before
moving to the next.
```

---

## Install (manual)

```text
/plugin marketplace add webdevtodayjason/dev-kit
/plugin install dev-kit@jason
```

Then **restart Claude Code** so skills, commands, agents, output styles, and the
context7 MCP register.

### Prerequisites (install these yourself first)

| Tool | Needed for | Install |
|---|---|---|
| **Node / npx** | the keyless `context7` docs MCP | comes with Node.js |
| **`uv`** | the optional `damage-control` security hooks (Python) | `brew install uv` |
| **`gh` CLI (authed)** | the review/commit workflows + `find-docs` | `brew install gh && gh auth login` |
| **`tmux`** | only if you later add team/orchestrator panes | `brew install tmux` |

None are required just to install — the skills and commands work without them; the
table notes what each *specific* feature needs.

---

## After install — 3 things to do

### 1. Adopt the CLAUDE.md template
Open `plugins/dev-kit/CLAUDE.template.md` (from this repo, or from the installed
plugin directory under `~/.claude/plugins/`) and copy it to your global or project
config:
```bash
cp plugins/dev-kit/CLAUDE.template.md ~/.claude/CLAUDE.md   # or a project ./CLAUDE.md
```
Then replace every `<PLACEHOLDER>` (your name, environment, secrets location,
follow-up file path, etc.) and **delete any section whose tooling you haven't installed.**

### 2. Choose a permission posture (start conservative)
This kit deliberately ships **no `settings.json`**. Set your own — and **do not**
copy a "full bypass" setup. Recommended starting point in `~/.claude/settings.local.json`:
```jsonc
{
  "permissions": {
    "deny": [
      "Bash(rm -rf /*)", "Bash(rm -rf ~/*)", "Bash(sudo rm -rf:*)",
      "Bash(mkfs:*)", "Bash(dd if=* of=/dev/*)"
    ],
    "ask": [ "Bash(git push --force:*)", "Bash(git reset --hard:*)" ]
  }
}
```
Leave `defaultMode` at the prompting default (or at most `acceptEdits`). **Do not** set
`CLAUDE_AUTONOMY`, `skipDangerousModePermissionPrompt`, or `skipAutoPermissionPrompt`
until you've deliberately decided you want them — they disable safety prompts and
neuter the deny/ask rules above.

### 3. Bring your own MCP credentials
- **context7** (docs lookup) — ships **keyless and works out of the box**. Optionally add your own `CONTEXT7_API_KEY` for higher rate limits.
- **Linear** — add the public server with *your own* key/OAuth (not bundled).
- **ghost.build** — install the current `ghost` CLI yourself and run `ghost login` for your own account (not bundled).
- **llm-council skill** — set `OPENAI_API_KEY` / `GEMINI_API_KEY` in your own `.env` (the shipped `.env.template` has only placeholders).

---

## Optional: enable the damage-control security hooks
The `damage-control` skill ships with a self-contained PreToolUse firewall (blocks
destructive shell commands and writes to credential paths). It's **not auto-wired** so
it can't break your tool calls on day one. To turn it on, install `uv`, then run the
`damage-control` skill and follow its install cookbook.

---

## What's included

- **Skills (24):** `tdd`, `diagnose`, `find-docs`, `write-a-skill`, `to-issues`, `to-prd`,
  `triage`, `code-review`-style review workflows, `grill-me`, `grill-with-docs`,
  `improve-codebase-architecture`, `context-audit`, `caveman`, `zoom-out`,
  `setup-matt-pocock-skills`, `damage-control`, `followup-closet`, `obsidian-vault`,
  `ghost-db`, `llm-council`, `prod-db-surgical`, `spec-driven-dev`, and
  `node` / `python` / `rust` conventions.
- **Commands:** `/code-review`, `/ai-slop-cleaner`, `/security-review`, `/commit`, `/geo-optimize`.
- **Agents:** `bug-analyzer`, `code-reviewer`, `dev-planner`, `story-generator`, `ui-sketcher`.
- **Output styles:** `coding-vibes`, `structural-thinking`.
- **MCP:** `context7` (keyless docs lookup).
- **`CLAUDE.template.md`:** fill-in operating instructions.
- **Statusline:** `plugins/dev-kit/statusline/statusline.sh` — a clean Claude Code status bar (project · branch · model · context % · tokens).
- **Terminal preset:** `plugins/dev-kit/terminal/starship.toml` + **`TERMINAL-SETUP.md`** — iTerm2 + Nerd Font + Starship, with an AI handoff prompt.

## What's intentionally NOT included
Anything machine-specific or private: orchestration tooling, secret managers,
personal infrastructure, business-project specifics, and **any credentials**. Bring
your own keys and your own conventions where they differ.

---

## Companion guides
- **[ONBOARDING.md](ONBOARDING.md)** — full macOS new-dev walkthrough (install Claude → paste-to-agent setup of the whole toolchain).
- **[TERMINAL-SETUP.md](TERMINAL-SETUP.md)** — iTerm2 + Nerd Font + Starship + the Claude statusline, with an AI handoff prompt.

---

Built by **Jason Brashear** — [jasonbrashear.com](https://jasonbrashear.com) · [Substack](https://jasonbrashear.substack.com) · [GitHub @webdevtodayjason](https://github.com/webdevtodayjason)
