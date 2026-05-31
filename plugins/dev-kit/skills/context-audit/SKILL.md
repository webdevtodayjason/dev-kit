---
name: context-audit
description: >-
  Audit your Claude Code static config for token waste and bloat. Use when
  the user says "audit my context", "context audit", "check my settings",
  "why is Claude so slow", "token optimization", or runs /context-audit.

  Reads the user's /context output to weight findings by actual token
  cost, then audits MCP servers, CLAUDE.md files, skills, settings.json,
  and permissions. Returns a health score with prioritized fixes.

  Scope: STATIC config only — settings, instruction files, MCP overhead,
  permission rules. Does NOT audit conversation-level bloat (oversized
  Bash outputs, repeat file reads, accumulating tool results) — that's a
  separate concern surfaced as a callout when relevant signals appear.
---

# Context Audit

Bloated static context costs more per turn AND degrades output quality
(the model has to wade through more noise to find what matters). This
skill measures the waste in your config and tells you what to cut.

## Step 1: Get /context data

Check the conversation history for /context output. If the user already
ran /context in this session, use that data and skip ahead.

If not, output exactly this and STOP:

> Run `/context` in this terminal and share the output. I'll wait — the
> token breakdown determines what to audit and in what order. Without
> it I'd be guessing at what's actually expensive in your setup.

Do NOT proceed to Step 2 until you have real /context numbers. The
audit pipeline below scores by actual token cost, not heuristics.

## Step 2: Audit by weight

Order the audit by descending token cost from /context. Whichever bucket
shows up biggest in the user's breakdown gets audited first. The
sections below are reference material, not a fixed sequence.

### MCP servers

Each connected server loads its tool definitions every turn. Cost varies
wildly — Playwright is ~15-20k tokens, a tiny custom server might be
under 1k.

- Pull the MCP overhead number directly from /context (do NOT estimate
  from server count)
- List configured servers from `~/.claude/settings.json` and any
  `settings.local.json`
- For each server, check if a CLI alternative exists with zero idle
  cost: Playwright (`npx playwright`), Google Workspace (`gcloud`),
  GitHub (`gh`), Linear (`linear-cli`), most cloud providers
- Flag servers whose token cost from /context exceeds 5% of the total
  context window AND have a CLI alternative

### CLAUDE.md files

Read all CLAUDE.md files (project root, `.claude/CLAUDE.md`,
`~/.claude/CLAUDE.md`). Count rules (lines that prescribe behavior, not
section headers or examples).

For each rule, apply five filters:

| Filter | Flag when... |
|---|---|
| Default | Claude already does this without being told |
| Contradiction | Conflicts with another rule in same or different CLAUDE.md |
| Redundancy | Repeats another rule already covered elsewhere |
| Bandaid | Added to fix one specific bad output, not improve outputs generally |
| Vague | Different reader interprets it differently ("be natural", "use good tone") |

**Recommendation tiers** (avoids the "looks-like-default-but-isn't" trap):

- **Cut** — rule is flagged by Default AND Vague together, OR is a
  Contradiction with a later rule. Both signals = high confidence the
  rule isn't load-bearing.
- **Review** — flagged by exactly one filter. Surface for the user's
  judgment, don't auto-recommend deletion. The user may have added it
  to fix a specific regression you can't see.
- **Keep but consolidate** — Redundancy alone (rule is correct but said
  twice). Recommend merging.

If total CLAUDE.md > 200 lines, also check for **progressive
disclosure** opportunities: rules that only apply to specific tasks
(deployment, testing, API conventions) should move to dedicated docs
with a one-line pointer in CLAUDE.md.

### Skills

Scan `~/.claude/skills/*/SKILL.md` and `.claude/skills/*/SKILL.md`. For
each:

- Count instruction lines (excluding code samples and tables)
- Apply the same five filters
- Watch for restated goals, hedging ("you may want to"), and synonyms
  ("be concise" + "keep it short" + "don't be verbose" all in one
  skill)

### Settings

Read `~/.claude/settings.json` and any project `settings.json` /
`settings.local.json`. Surface these settings:

| Setting | Why it matters | Suggested |
|---|---|---|
| `autocompact_percentage_override` | Controls when context auto-compacts. Lower = more frequent compaction = less bloat per turn | Try 75 if unset; raise if compaction is interrupting useful work |
| `BASH_MAX_OUTPUT_LENGTH` (env) | Default cap on Bash output stored in context | Raise if you frequently truncate; lower if you don't | 

Don't blanket-prescribe specific values — the right number depends on
the user's typical workload. Surface the current value, the rationale
for changing, and let the user pick.

### File permissions

Check `permissions.deny` in settings.json. If absent, check whether
known-bloat directories exist in the working tree:

| Project signal | Should consider denying |
|---|---|
| `package.json` exists | `node_modules`, `dist`, `build`, `.next`, `coverage` |
| `Cargo.toml` exists | `target` |
| `go.mod` exists | `vendor` |
| `pyproject.toml` / `requirements.txt` | `__pycache__`, `.venv`, `*.egg-info` |
| `*.lock` artifacts | `.terraform`, `.serverless` |

## Step 3: Score and report

Score starts at 100. Apply at most ONE penalty per item — when multiple
tiers apply, take the higher penalty only (no stacking).

| Issue | Penalty |
|---|---|
| MCP overhead > 20% of context window | -15 |
| MCP overhead 10-20% of context window | -8 |
| MCP overhead 5-10% with CLI alternative available | -5 |
| CLAUDE.md ≥ 30% of rules flagged "Cut" | -15 |
| CLAUDE.md 15-30% of rules flagged "Cut" | -8 |
| Contradictions between CLAUDE.md files | -10 |
| Skill ≥ 30% of instruction lines flagged | -8 each |
| Skill 15-30% of instruction lines flagged | -4 each |
| Missing autocompact_percentage_override (no project-specific reason) | -5 |
| Missing BASH_MAX_OUTPUT_LENGTH override (often-truncated outputs) | -5 |
| No `permissions.deny` rules + known bloat dirs exist | -10 |

Floor at 0.

**Output format:**

```
# Context Audit

Score: {N}/100 [{CLEAN | NEEDS WORK | BLOATED | CRITICAL}]

## Context Breakdown (from /context)
{Top 3-5 token consumers with their %}

## Top 3 Fixes
1. {Highest-impact actionable fix with expected token savings}
2. {Second}
3. {Third}

## Issues by Category

### [{CRITICAL | WARNING | INFO}] {Category}
{What's bloated}
Fix: {One-line actionable recommendation}

### Rules to Cut (high confidence)
{Each Default+Vague or Contradiction rule: text + which filters tripped}

### Rules to Review (one filter triggered)
{Each rule flagged by exactly one filter — surface for user judgment}

### Conflicts
{Contradictions between files, with paths}
```

**Score labels:**
- 90-100: CLEAN
- 70-89: NEEDS WORK
- 50-69: BLOATED
- 0-49: CRITICAL

**Severity tiers** (for the per-category callouts):
- CRITICAL: penalty ≥ 10
- WARNING: penalty 5-10
- INFO: penalty < 5

## Step 4: Conversation-level callout (when applicable)

This skill audits static config only, but if the conversation history
shows obvious live bloat, mention it as a separate callout (don't
factor into the score):

- Tool result > 50KB in a single Bash output → suggest output
  redirection to file + Read pattern
- Same file Read 3+ times in one session → could have been cached or
  remembered
- Multiple background tasks accumulating output without being checked

Format as: "Live bloat noticed (not in score): {observation}. Consider
{fix}." This is a tip, not a deduction.

## Step 5: Offer to fix

After the report:

> Want me to apply any of these? I can:
> - Show you a cleaned-up CLAUDE.md with the high-confidence cuts removed (diff first, you confirm)
> - Add the missing settings.json configs (diff first, you confirm)
> - Add `permissions.deny` rules for build artifacts (diff first, you confirm)
> - Show which skills to compress and where

**Always show the diff and wait for confirmation** before modifying any
config or instruction file — including `permissions.deny`. Even
"reversible" deny rules can interrupt active debugging if the user is
mid-investigation in a denied directory. Don't auto-apply anything.

If the user confirms, write the changes. If they say "all yes", batch
the edits in one pass and report what landed.

## Anti-patterns to avoid

- **Don't penalize line count alone.** A 500-line CLAUDE.md of essential
  rules is fine; a 100-line CLAUDE.md of junk is not. Always weight by
  flagged-rule ratio.
- **Don't hard-code "correct" values for settings.** What's right for
  one user's workload is wrong for another. Surface tradeoffs.
- **Don't flag a rule as "cut" on a single filter.** One signal could
  be a false positive. Require two signals (Default + Vague, or
  Contradiction) to recommend deletion. Single-filter rules go to
  "Review" for the user's judgment.
- **Don't treat MCP servers as fungible.** Penalty must be proportional
  to actual token cost from /context, not server count.
- **Don't auto-apply config changes.** Always diff + confirm.
