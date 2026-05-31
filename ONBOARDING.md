# New Developer Onboarding — macOS & Linux

A two-part walkthrough to take a fresh machine to a fully working dev environment for
our stack. Works on **macOS** (Apple Silicon or Intel) and **Linux** (Debian/Ubuntu,
Fedora, Arch — including ARM boxes like a Raspberry Pi). **Part 1** you do by hand
(install + sign in to Claude). **Part 2** is a single prompt you paste into Claude — it
detects your OS, installs everything else, and walks you through authorizing each
service with **your own** accounts.

> You'll need: a Mac or Linux machine, admin/sudo rights, and accounts for GitHub,
> Railway, Docker Hub, and Anthropic (Claude). Your team lead will send org invites and
> tell you which repos to clone.

---

## Part 1 — Install & authenticate Claude Code (do this yourself)

1. **Open a terminal.**

2. **Install Claude Code** (the native installer works on macOS *and* Linux):
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
   *(Alternatives: the macOS app from https://claude.com/claude-code, or
   `npm install -g @anthropic-ai/claude-code` if you already have Node. If `claude`
   isn't found afterward, open a new terminal — the installer puts it in `~/.local/bin`.)*

3. **Start Claude and sign in:**
   ```bash
   claude
   ```
   Run `/login`, authenticate with your Claude (Pro/Max) account or an Anthropic API
   key, and confirm with `/status`.

4. **`cd` into where your code will live** (Part 2 uses `~/code`):
   ```bash
   mkdir -p ~/code && cd ~/code
   claude
   ```

Once Claude is running and authenticated, go to Part 2.

---

## Part 2 — Paste this to Claude

Copy the entire block below into your Claude session. It detects your OS, sets up the
toolchain, guides every login, installs our shared workflow (`dev-kit`), and clones +
bootstraps the repos your lead assigns.

```text
You are setting up a brand-new developer machine (macOS OR Linux) for someone joining
our team. Drive this end to end, following these rules the whole way:

RULES
- FIRST detect the OS and package manager and tell me what you found: macOS -> Homebrew
  (brew); Debian/Ubuntu -> apt; Fedora -> dnf; Arch -> pacman. Use that PM for every
  install below. Detect the architecture too (Apple Silicon, x86_64, or arm64/aarch64).
- Work phase by phase. Show me what you're about to do; for anything that installs
  software, tell me first and wait for my go.
- For INTERACTIVE / browser logins (gh, railway, docker, ghost) you cannot complete
  them yourself — give me the exact command, have me run it, wait for me to confirm,
  then verify with a status command and show the result.
- NEVER write secrets/tokens/keys into any committable file. Use .env files (confirm
  they're gitignored). Every service uses MY OWN account.
- After each phase, print a one-line ✅/❌ status.

PHASE 0 — Sanity
- Print OS, distro/version, architecture, and the package manager you'll use.
- macOS: ensure Xcode Command Line Tools (`xcode-select --install` if missing).
- Linux: ensure base build tools + curl + git are present (Debian/Ubuntu:
  `sudo apt install build-essential curl git`; Fedora: `@development-tools`; Arch:
  `base-devel`). Refresh package lists first (`sudo apt update`, etc.).

PHASE 1 — Package manager
- macOS: if `brew` is missing, give me the official install one-liner from brew.sh,
  then confirm `brew --version` and that brew is on PATH.
- Linux: the native PM is already there; just confirm it works and lists are updated.

PHASE 2 — Core CLI tools (via the detected PM, after my go)
- git, gh (GitHub CLI), jq, tmux, ripgrep, wget.
- Note: on Debian/Ubuntu, `gh` may need GitHub's apt repo added first — offer to do it.

PHASE 3 — Language runtimes (these install scripts are cross-platform)
- Node: install fnm (or nvm), then current LTS Node; confirm `node -v` / `npx -v`.
- Bun: official install script; confirm `bun -v`. (Our JS/TS projects are Bun-first.)
- Python: install `uv` (we use uv + ruff, not system Python); confirm `uv --version`.
- Rust (only if I'll touch Rust repos): rustup; confirm `cargo --version`.

PHASE 4 — Containers
- macOS: OrbStack (lighter) or Docker Desktop — install the one I pick, have me launch
  + sign in.
- Linux: Docker Engine (official convenience script at get.docker.com, or distro
  packages) or Podman; add my user to the `docker` group (`sudo usermod -aG docker $USER`,
  then a re-login). 
- Verify on both: `docker run --rm hello-world`.

PHASE 5 — Deploy tooling (Railway)
- Install the Railway CLI (`npm i -g @railway/cli`, or brew on macOS, or the official
  script on Linux). We deploy on Railway; its builder is railpack (no separate CLI).
- Confirm `railway --version`.

PHASE 6 — Database tooling
- Install `psql`: macOS `brew install libpq` (and link it); Debian/Ubuntu
  `sudo apt install postgresql-client`; Fedora `sudo dnf install postgresql`.
- Install the ghost.build CLI (ephemeral/forkable Postgres) from https://ghost.build;
  confirm `ghost --version`.

PHASE 7 — Authenticate everything (interactive — guide me, then verify)
- GitHub:  I run `gh auth login` (HTTPS, browser). Verify `gh auth status`.
- Railway: I run `railway login`. Verify `railway whoami`.
- Docker:  I sign in (Docker Desktop/OrbStack app on macOS, or `docker login` on Linux).
  Verify `docker info` shows my account.
- ghost:   I run `ghost login`. Verify `ghost status`.
- Tell me which GitHub org invites and Railway project access to expect from my lead;
  have me confirm I've accepted them before continuing.

PHASE 8 — Our shared Claude workflow (dev-kit)
- Run `/plugin marketplace add webdevtodayjason/dev-kit` then `/plugin install dev-kit@jason`.
  (CLI equivalent if you prefer scripting: `claude plugin marketplace add
  webdevtodayjason/dev-kit && claude plugin install dev-kit@jason` — works on macOS and Linux.)
- Companion plugins (see STACK.md): offer to install claude-mem, CodeRabbit, Codex,
  Ralph Wiggum (swift-lsp only for Swift) and the Linear / ghost MCPs with MY own keys.
  Ask which I want; don't assume all.
- Tell me to restart Claude Code so everything registers.
- Copy `CLAUDE.template.md` from the installed dev-kit plugin to `~/.claude/CLAUDE.md`,
  then interview me to fill every <PLACEHOLDER>.
- Set a CONSERVATIVE permission posture in `~/.claude/settings.local.json`: a deny list
  for catastrophic commands (rm -rf /*, rm -rf ~/*, sudo rm -rf, mkfs, dd ... of=/dev/*)
  and an ask list (git push --force, git reset --hard). Do NOT enable bypassPermissions,
  CLAUDE_AUTONOMY, or any skip-prompt flags.

PHASE 9 — Clone & bootstrap the repos
- Ask which repos my lead assigned (and which GitHub orgs they're under).
- Clone each into `~/code/<repo>`.
- For each repo, read its README and CLAUDE.md and run the setup it specifies: typically
  `bun install` (or `npm install`), `uv sync` for Python, `cp .env.example .env` (then
  pause so I can fill in real values), `npx prisma generate` if it uses Prisma, and any
  docker-compose for local services. Do NOT run migrations against a shared/prod
  database — use a local or forked DB.

PHASE 10 — Verify & smoke test
- Print a summary table: tool -> version -> auth status for git, gh, node, bun, uv,
  docker, railway, ghost, claude (plus the detected OS/arch).
- Run quick checks: `gh auth status`, `railway whoami`, `docker run --rm hello-world`,
  `bun -v`. Flag anything red.
- Run `/context-audit` and confirm the dev-kit skills/commands are loaded.

When everything is green, summarize what's installed and what I still need from my lead
(org access, env values, Railway project links).
```

---

## Terminal setup
Once the toolchain's in, make your terminal nice (prompt + statusline + Nerd Font) —
see **[TERMINAL-SETUP.md](TERMINAL-SETUP.md)** (covers both macOS and Linux).

---

## After setup — what your lead provides separately

Intentionally **not** in this public file. Your lead will give you:
- GitHub **org invites** and the **list of repos** to clone (Phase 9).
- **Railway project** access / links.
- **`.env` values** for each repo (real secrets — never committed).
- Any **VPN / network** access for internal services.

---

## Troubleshooting

- **`claude: command not found`** → open a new terminal, or add `~/.local/bin` to PATH.
- **`brew` not found** (macOS) → run the `eval` line Homebrew prints after install.
- **`docker` permission denied** (Linux) → you didn't re-login after `usermod -aG docker`;
  log out/in or run `newgrp docker`.
- **`docker` daemon errors** (macOS) → Docker Desktop / OrbStack must be *running*.
- **A login "succeeds" but verify fails** → wrong account; log out (`gh auth logout` /
  `railway logout`) and redo.
- **Stuck?** Ask Claude — it has the `diagnose` skill from dev-kit.

---

*Part of the [dev-kit](https://github.com/webdevtodayjason/dev-kit) onboarding toolkit.*
