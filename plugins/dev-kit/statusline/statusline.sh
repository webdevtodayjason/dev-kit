#!/usr/bin/env bash
# statusline.sh — a clean Claude Code statusline (standalone; no external services).
#
# Renders one line:  <project> │ <branch><dirty> │ <model> │ ctx <N>% │ ↑<in> ↓<out>
#
# Reads the Claude Code statusLine JSON on stdin. Only dependencies are `jq`,
# `git`, and a 256-color UTF-8 terminal. No accounts, no rate-limit radar, no
# private infrastructure — just the useful local signals.
#
# Install:
#   1. cp this file to ~/.claude/scripts/statusline.sh && chmod +x ~/.claude/scripts/statusline.sh
#   2. add to ~/.claude/settings.json:
#        "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh" }
set -uo pipefail

input=$(cat)

# --- parse the statusLine JSON ---
project=$(printf '%s' "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // "."' | xargs -0 basename 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "."')
model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')

# --- git: branch + dirty/untracked indicator ---
branch="" gstatus=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null || gstatus="*"
  [[ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]] && gstatus="${gstatus}+"
fi
[[ -z "$branch" ]] && branch="no-git"

# --- context-window usage % ---
ctx_pct=0
usage=$(printf '%s' "$input" | jq -c '.context_window.current_usage // null')
if [[ "$usage" != "null" ]]; then
  curr=$(printf '%s' "$usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
  out=$(printf '%s' "$usage" | jq '.output_tokens // 0')
  size=$(printf '%s' "$input" | jq '.context_window.context_window_size // 200000')
  [[ "$size" -gt 0 ]] && ctx_pct=$(( (curr + out) * 100 / size ))
fi

# --- session token totals ---
tin=$(printf '%s' "$input" | jq '.context_window.total_input_tokens // 0')
tout=$(printf '%s' "$input" | jq '.context_window.total_output_tokens // 0')

# --- helpers (inline; no external libs) ---
fmt() {  # 1234 -> 1.2k, 1500000 -> 1.5M
  local n=${1:-0}
  if   (( n >= 1000000 )); then printf '%d.%dM' $(( n / 1000000 )) $(( (n % 1000000) / 100000 ))
  elif (( n >= 1000 ));    then printf '%d.%dk' $(( n / 1000 ))    $(( (n % 1000) / 100 ))
  else printf '%d' "$n"; fi
}
ctx_color() {  # green <50, yellow <75, orange <90, red >=90
  local p=${1:-0}
  if   (( p >= 90 )); then printf '196'
  elif (( p >= 75 )); then printf '208'
  elif (( p >= 50 )); then printf '220'
  else printf '78'; fi
}

# --- render ---
RESET='\033[0m'
BAR='\033[38;5;240m│\033[0m'
C_PROJ='\033[38;5;51m'      # cyan
C_BRANCH='\033[38;5;205m'   # pink
C_MODEL='\033[38;5;141m'    # purple
C_TOK='\033[38;5;220m'      # gold
C_CTX="\033[38;5;$(ctx_color "$ctx_pct")m"

out=""
out+="${C_PROJ}${project}${RESET} ${BAR} "
out+="${C_BRANCH}${branch}${gstatus}${RESET} ${BAR} "
out+="${C_MODEL}${model}${RESET} ${BAR} "
out+="${C_CTX}ctx ${ctx_pct}%${RESET} ${BAR} "
out+="${C_TOK}↑$(fmt "$tin") ↓$(fmt "$tout")${RESET}"
printf '%b\n' "$out"
