# Terminal Setup — macOS & Linux

Make a new machine's terminal look and work like ours: a good **terminal**, a **Nerd
Font** so icons render, **Starship** for the shell prompt (with our preset), and the
**Claude Code statusline** (the bar inside Claude showing project / git / model /
context / tokens).

Works on **macOS** and **Linux**. The only OS-specific piece is the terminal app
itself — iTerm2 is macOS-only; on Linux pick any modern terminal. Everything else
(Nerd Font, Starship, statusline) is cross-platform — the statusline is even proven on
Linux ARM (a Raspberry Pi).

Two ways: the [manual guide](#manual-guide), or [hand it to your agent](#hand-it-to-your-agent).

Assets shipped in this repo:
- `plugins/dev-kit/terminal/starship.toml` — the Starship preset (two-line, language-aware)
- `plugins/dev-kit/statusline/statusline.sh` — the Claude statusline script

---

## Manual guide

### 1. A terminal
- **macOS:** `brew install --cask iterm2`
- **Linux:** any modern terminal with TrueColor + custom-font support — e.g.
  **Ghostty**, **Alacritty** (`sudo apt install alacritty`), **Konsole** (KDE), or
  **GNOME Terminal** (preinstalled on GNOME). Pick one.

### 2. A Nerd Font (required for icons)
- **macOS:**
  ```bash
  brew install --cask font-meslo-lg-nerd-font
  ```
  Then set it: **⌘, → Profiles → Text → Font → a "MesloLG Nerd Font"** (e.g. *MesloLGS
  Nerd Font*).
- **Linux:**
  ```bash
  mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  unzip -o Meslo.zip && rm Meslo.zip && fc-cache -f
  ```
  Then set the font in your terminal's settings (GNOME Terminal → Preferences →
  Profile → Text → Custom font → "MesloLGS Nerd Font"; Alacritty → `font.normal.family`
  in `alacritty.toml`; Konsole → Edit Profile → Appearance → Font).

Without a Nerd Font, the prompt/statusline icons show as boxes (□).

### 3. Starship (shell prompt) — cross-platform
```bash
# install
brew install starship                              # macOS
curl -sS https://starship.rs/install.sh | sh       # Linux (or your distro package)

# enable in your shell (zsh shown; use ~/.bashrc for bash):
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# drop in the preset (back up any existing config first):
mkdir -p ~/.config
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml ~/.config/starship.toml.bak
cp plugins/dev-kit/terminal/starship.toml ~/.config/starship.toml
```
Open a new tab — two-line prompt: directory · git branch/status · language versions ·
time, with a clean `❯` input line.

### 4. Claude Code statusline — cross-platform
```bash
mkdir -p ~/.claude/scripts
cp plugins/dev-kit/statusline/statusline.sh ~/.claude/scripts/statusline.sh
chmod +x ~/.claude/scripts/statusline.sh
```
Add to `~/.claude/settings.json` (merge into the existing object — don't overwrite):
```json
{
  "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh" }
}
```
Restart Claude Code. The bar shows: `project │ branch* │ model │ ctx N% │ ↑in ↓out`,
context % shifting green → gold → orange → red as it fills. (Needs `jq` + `git` — both
from the main [onboarding](ONBOARDING.md).)

---

## Hand it to your agent

Paste this into your Claude session (run it from inside the `dev-kit` repo, or it'll
fetch the files from GitHub):

```text
Set up my terminal to match our team's environment. First detect my OS (macOS or
Linux) and use the right steps below. Rules:
- Install via the OS package manager; show each step and wait for my go before installing.
- For GUI steps (setting the terminal font), give me the exact click-path and wait for me.
- Back up any file you replace (e.g. cp ~/.config/starship.toml{,.bak} if it exists).
- Merge into existing config files (settings.json, .zshrc) — never clobber them.

1. Terminal:
   - macOS: `brew install --cask iterm2`.
   - Linux: confirm I have a modern terminal (Ghostty/Alacritty/Konsole/GNOME Terminal);
     offer to install Alacritty via my package manager if I want one.
2. Nerd Font:
   - macOS: `brew install --cask font-meslo-lg-nerd-font`.
   - Linux: download MesloLG Nerd Font into ~/.local/share/fonts and run `fc-cache -f`
     (from https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip).
3. Set the font (GUI — guide me): tell me the exact path to choose a "MesloLG Nerd Font"
   in my terminal's settings, and wait for my confirmation. Icons won't render until set.
4. Starship: install (macOS `brew install starship`; Linux `curl -sS https://starship.rs/install.sh | sh`),
   then append `eval "$(starship init zsh)"` to ~/.zshrc if not present (use ~/.bashrc for bash).
5. Starship preset: copy `plugins/dev-kit/terminal/starship.toml` to ~/.config/starship.toml
   (back up any existing one). If you don't have the repo locally, fetch it from
   https://raw.githubusercontent.com/webdevtodayjason/dev-kit/main/plugins/dev-kit/terminal/starship.toml
6. Claude statusline: copy `plugins/dev-kit/statusline/statusline.sh` to
   ~/.claude/scripts/statusline.sh (chmod +x), and add to ~/.claude/settings.json:
   "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh" }
   (raw URL if needed:
   https://raw.githubusercontent.com/webdevtodayjason/dev-kit/main/plugins/dev-kit/statusline/statusline.sh )
7. Verify: have me open a new terminal tab (expect the two-line Starship prompt with
   icons) and restart Claude Code (expect the statusline bar).
Confirm each step before moving on. Don't touch my secrets or unrelated settings.
```

---

## Notes
- **iTerm2 is macOS-only.** On Linux, Starship + the Nerd Font work in any of the
  terminals above — the look is identical.
- The **statusline is terminal-independent** — it lives inside Claude Code and runs
  anywhere Claude runs (macOS, Linux x86, Linux ARM).
- Tune `starship.toml` freely; it's a starting point, not a mandate.

*Part of the [dev-kit](https://github.com/webdevtodayjason/dev-kit) onboarding toolkit.*
