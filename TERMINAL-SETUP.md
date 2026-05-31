# Terminal Setup — iTerm2 · Nerd Font · Starship · Claude statusline

Make a new machine's terminal look and work like ours: **iTerm2** as the terminal,
a **Nerd Font** so icons render, **Starship** for the shell prompt (with our preset),
and the **Claude Code statusline** (the bar inside Claude showing project / git /
model / context / tokens).

Two ways to do it: the [manual guide](#manual-guide), or [hand it to your agent](#hand-it-to-your-agent).

Assets shipped in this repo:
- `plugins/dev-kit/terminal/starship.toml` — the Starship preset (two-line, language-aware)
- `plugins/dev-kit/statusline/statusline.sh` — the Claude statusline script

---

## Manual guide

### 1. iTerm2
```bash
brew install --cask iterm2
```

### 2. A Nerd Font (required for icons)
```bash
brew install --cask font-meslo-lg-nerd-font
```
Then point iTerm2 at it — **⌘, → Profiles → Text → Font → pick a "MesloLG Nerd Font"**
(e.g. *MesloLGS Nerd Font*). Without a Nerd Font, the prompt/statusline icons show as
boxes (□).

### 3. Starship (shell prompt)
```bash
brew install starship
# add the initializer to your shell (zsh shown; use ~/.bashrc for bash):
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
# drop in the preset (back up any existing config first):
mkdir -p ~/.config
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml ~/.config/starship.toml.bak
cp plugins/dev-kit/terminal/starship.toml ~/.config/starship.toml
```
Open a new tab — you'll get a two-line prompt: directory · git branch/status ·
language versions · time, with a clean `❯` input line.

### 4. Claude Code statusline
```bash
mkdir -p ~/.claude/scripts
cp plugins/dev-kit/statusline/statusline.sh ~/.claude/scripts/statusline.sh
chmod +x ~/.claude/scripts/statusline.sh
```
Then add this to `~/.claude/settings.json` (merge into the existing object — don't
overwrite the file):
```json
{
  "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh" }
}
```
Restart Claude Code. The bar shows: `project │ branch* │ model │ ctx N% │ ↑in ↓out`,
with the context % shifting green → gold → orange → red as it fills.

---

## Hand it to your agent

Paste this into your Claude session (run it from inside the `dev-kit` repo, or it'll
fetch the files from GitHub):

```text
Set up my macOS terminal to match our team's environment: iTerm2 + a Nerd Font +
Starship (with our preset) + the Claude Code statusline. Rules:
- Install via Homebrew; show me each step and wait for my go before installing.
- For GUI steps (the iTerm2 font), give me the exact click-path and wait for me to confirm.
- Back up any file you replace (e.g. cp ~/.config/starship.toml{,.bak} if it exists).
- Merge into existing config files (settings.json, .zshrc) — never clobber them.

1. iTerm2: `brew install --cask iterm2` (skip if installed).
2. Nerd Font: `brew install --cask font-meslo-lg-nerd-font`.
3. iTerm2 font (GUI — guide me): tell me to open iTerm2 -> ⌘, -> Profiles -> Text ->
   Font, and choose a "MesloLG Nerd Font" (e.g. MesloLGS Nerd Font); wait for my
   confirmation. Icons won't render until this is set.
4. Starship: `brew install starship`, then append `eval "$(starship init zsh)"` to
   ~/.zshrc if it's not already there (use ~/.bashrc if I use bash).
5. Starship preset: copy `plugins/dev-kit/terminal/starship.toml` to
   ~/.config/starship.toml (back up any existing one). If you don't have the repo
   locally, fetch the file from
   https://raw.githubusercontent.com/webdevtodayjason/dev-kit/main/plugins/dev-kit/terminal/starship.toml
6. Claude statusline: copy `plugins/dev-kit/statusline/statusline.sh` to
   ~/.claude/scripts/statusline.sh (chmod +x), and add to ~/.claude/settings.json:
   "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh" }
   (raw URL if needed:
   https://raw.githubusercontent.com/webdevtodayjason/dev-kit/main/plugins/dev-kit/statusline/statusline.sh )
7. Verify: have me open a new iTerm2 tab (expect the two-line Starship prompt with
   icons), and restart Claude Code (expect the statusline bar).
Confirm each step before moving on. Don't touch my secrets or unrelated settings.
```

---

## Notes
- The statusline needs `jq` and `git` on PATH (both installed in the main [onboarding](ONBOARDING.md)).
- Prefer a lighter terminal? Starship + the Nerd Font work in any terminal (Ghostty,
  WezTerm, Terminal.app); iTerm2 is just our default. The statusline is independent of
  the terminal — it lives inside Claude Code.
- Tune `starship.toml` freely; it's a starting point, not a mandate.

*Part of the [dev-kit](https://github.com/webdevtodayjason/dev-kit) onboarding toolkit.*
