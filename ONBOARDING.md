# New Developer Onboarding — macOS

A two-part walkthrough to take a fresh MacBook Pro to a fully working dev
environment for our stack. **Part 1** you do by hand (install + sign in to Claude).
**Part 2** is a single prompt you paste into Claude — it installs and configures
everything else and walks you through authorizing each service with **your own**
accounts.

> You'll need: a Mac (Apple Silicon or Intel), admin rights, and accounts for
> GitHub, Railway, Docker Hub, and Anthropic (Claude). Your team lead will send
> org invites and tell you which repos to clone.

---

## Part 1 — Install & authenticate Claude Code (do this yourself)

1. **Open Terminal** (⌘-Space → "Terminal").

2. **Install Claude Code** (native installer — no Node required yet):
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
   *(Alternatives: the macOS app from https://claude.com/claude-code, or `npm install -g @anthropic-ai/claude-code` if you already have Node. If `claude` isn't found after install, open a new Terminal tab.)*

3. **Start Claude and sign in:**
   ```bash
   claude
   ```
   Then run `/login` and authenticate with your Claude (Pro/Max) account or an
   Anthropic API key. Confirm you're in with `/status`.

4. **`cd` into where your code will live** (Part 2 uses `~/code`):
   ```bash
   mkdir -p ~/code && cd ~/code
   claude
   ```

Once Claude is running and authenticated, go to Part 2.

---

## Part 2 — Paste this to Claude

Copy the entire block below into your Claude session. It will set up the toolchain,
guide you through every login, install our shared Claude workflow (`dev-kit`), and
clone + bootstrap the repos your lead assigns.

```text
You are setting up a brand-new macOS machine for a developer joining our team.
Drive this end to end, but follow these rules the whole way:

RULES
- Work phase by phase. Show me what you're about to do; for anything that installs
  software, tell me first and wait for my go.
- For INTERACTIVE / browser logins (gh, railway, docker, ghost), you cannot
  complete them yourself — give me the exact command, have me run it, wait for me
  to say it's done, then verify with a status command and show the result.
- NEVER write secrets, tokens, or API keys into any file that could be committed.
  Use .env files (and confirm they're gitignored). Every service uses MY OWN
  account — never reuse anyone else's credentials.
- After each phase, print a one-line ✅/❌ status so we both know where we are.

PHASE 0 — Sanity
- Confirm macOS + chip (Apple Silicon vs Intel). Ensure Xcode Command Line Tools
  are present; if not, tell me to run `xcode-select --install` and wait.

PHASE 1 — Homebrew
- If `brew` is missing, give me the official install one-liner from brew.sh to run
  myself, then confirm `brew --version`. Make sure brew is on my PATH.

PHASE 2 — Core CLI tools (via brew, after my go)
- git, gh (GitHub CLI), jq, tmux, wget, ripgrep.

PHASE 3 — Language runtimes
- Node: install fnm (or nvm), then the current LTS Node; confirm `node -v`/`npx -v`.
- Bun: install via brew or the official script; confirm `bun -v`. (Our JS/TS
  projects are Bun-first.)
- Python: install `uv` (we use uv + ruff, not system Python); confirm `uv --version`.
- Rust (only if I'll touch Rust repos): install via rustup; confirm `cargo --version`.

PHASE 4 — Containers
- Recommend OrbStack (lighter) or Docker Desktop. Install the one I pick, have me
  launch + sign in, then verify with `docker run --rm hello-world`.

PHASE 5 — Deploy tooling (Railway)
- Install the Railway CLI (`brew install railway` or the official script). We deploy
  on Railway; its builder is railpack (no separate CLI to install).
- Confirm `railway --version`.

PHASE 6 — Database tooling
- Install `psql` (libpq) for Postgres access.
- Install the ghost.build CLI (we use it for ephemeral/forkable Postgres):
  point me at https://ghost.build to install the current version. Confirm `ghost --version`.

PHASE 7 — Authenticate everything (interactive — guide me, then verify)
- GitHub:  I run `gh auth login` (choose HTTPS, authenticate via browser). Verify `gh auth status`.
- Railway: I run `railway login`. Verify `railway whoami`.
- Docker:  I sign in in the Docker/OrbStack app (or `docker login`). Verify `docker info` shows my account.
- ghost:   I run `ghost login`. Verify `ghost status` (or the equivalent).
- Tell me which GitHub org invites and Railway project access I should expect from
  my team lead, and have me confirm I've accepted them before continuing.

PHASE 8 — Our shared Claude workflow (dev-kit)
- Run `/plugin marketplace add webdevtodayjason/dev-kit` then `/plugin install dev-kit@jason`.
- Companion plugins (see STACK.md in the repo): offer to install our team's other
  plugins — claude-mem, CodeRabbit, Codex, Ralph Wiggum (swift-lsp only for Swift) —
  and the Linear / ghost MCPs with MY own keys. Ask which I want; don't assume all.
- Tell me to restart Claude Code so skills/commands/agents/MCP register.
- Copy `CLAUDE.template.md` from the installed dev-kit plugin to `~/.claude/CLAUDE.md`,
  then interview me to fill in every <PLACEHOLDER>.
- Set a CONSERVATIVE permission posture in `~/.claude/settings.local.json`: a deny
  list for catastrophic commands (rm -rf /*, rm -rf ~/*, sudo rm -rf, mkfs,
  dd ... of=/dev/*) and an ask list (git push --force, git reset --hard). Do NOT
  enable bypassPermissions, CLAUDE_AUTONOMY, or any skip-prompt flags.

PHASE 9 — Clone & bootstrap the repos
- Ask me which repos my lead assigned (and which GitHub orgs they're under).
- Clone each into `~/code/<repo>`.
- For each repo, read its README and CLAUDE.md and run the setup it specifies:
  typically `bun install` (or `npm install`), `uv sync` for Python, `cp .env.example .env`
  (then pause so I can fill in real values), `npx prisma generate` if it uses Prisma,
  and any docker-compose for local services. Do NOT run migrations against any
  shared/prod database — set up a local or forked DB instead.

PHASE 10 — Verify & smoke test
- Print a summary table: tool -> version -> auth status for git, gh, node, bun, uv,
  docker, railway, ghost, claude.
- Run quick smoke checks: `gh auth status`, `railway whoami`, `docker run --rm hello-world`,
  and `bun -v`. Flag anything red.
- Run `/context-audit` and confirm the dev-kit skills/commands are loaded.

When everything is green, summarize what's installed and what I still need from my
team lead (org access, env values, Railway project links).
```

---

## After setup — what your lead provides separately

These are intentionally **not** in this public file. Your team lead will give you:

- GitHub **org invites** and the **list of repos** to clone (Phase 9).
- **Railway project** access / links and any deploy permissions.
- **`.env` values** for each repo (real secrets — never committed; you'll paste them
  into local `.env` files during Phase 9).
- Any **VPN / network** access needed for internal services.

---

## Troubleshooting

- **`claude: command not found`** after install → open a new Terminal tab, or add the
  install dir to your PATH (the installer prints it).
- **`brew` not found** after install → run the "Next steps" `eval` line Homebrew prints
  (adds brew to your shell profile).
- **`docker` daemon errors** → make sure Docker Desktop / OrbStack is *running*, not
  just installed.
- **A login "succeeds" but verify fails** → you may have authed a different account;
  log out (`gh auth logout` / `railway logout`) and redo with the right one.
- **Stuck?** Ask Claude — it has the `diagnose` skill from dev-kit.

---

*Part of the [dev-kit](https://github.com/webdevtodayjason/dev-kit) onboarding toolkit.*
