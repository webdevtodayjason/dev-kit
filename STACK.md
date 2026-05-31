# Recommended Stack — companion plugins & MCPs

`dev-kit` ships our **skills, commands, agents, output styles, statusline, and
conventions**. The rest of the team workflow comes from a few **separate plugins and
MCP servers** — dev-kit can't bundle them (they live in their own marketplaces), so
install the ones you need here. Everything below uses **your own** accounts/keys.

> Each plugin install is two lines: add the marketplace, then install the plugin.
> Restart Claude Code afterward so it registers.

---

## Plugins

### claude-mem — cross-session memory *(recommended)*
Captures what you do each session and feeds it back later. The `Memory System`
section of `CLAUDE.template.md` assumes this is installed.
```text
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem@thedotmack
```

### CodeRabbit — AI code review
```text
/plugin marketplace add coderabbitai/claude-plugin
/plugin install coderabbit@coderabbit
```

### Codex — second-opinion / rescue
A GPT-backed reviewer/implementer you can hand stuck or deep-dive work to.
```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
```

### Ralph Wiggum — autonomous loop technique
Runs a prompt/command on a loop until a goal is met.
```text
/plugin marketplace add anthropics/claude-code
/plugin install ralph-wiggum@claude-code-plugins
```

### swift-lsp — Swift language server *(optional — iOS/Swift repos only)*
```text
/plugin marketplace add anthropics/claude-plugins-official
/plugin install swift-lsp@claude-plugins-official
```

**Skip these:** `document-skills` and `example-skills` (`anthropics/skills`) — the
document skills already ship with the stock Claude distribution.

---

## MCP servers

### context7 — docs lookup *(already bundled)*
Ships keyless inside dev-kit (`plugins/dev-kit/.mcp.json`). Nothing to do; optionally
add your own `CONTEXT7_API_KEY` for higher rate limits.

### Linear — issue tracking *(your own key)*
Get a personal API key from Linear → Settings → Security & access → API, then:
```text
claude mcp add linear --env LINEAR_API_KEY=<your-linear-api-key> -- npx -y @tacticlaunch/mcp-linear
```
*(Or use Linear's hosted OAuth MCP if you prefer not to manage a key.)*

### ghost.build — ephemeral/forkable Postgres *(your own account)*
dev-kit ships the `ghost-db` skill; it needs the ghost CLI on your machine:
```text
# install the ghost CLI from https://ghost.build, then:
ghost login            # your own account
ghost mcp install      # registers the ghost MCP with Claude Code
```

---

## Your own marketplace (team plugins)

You also publish **`webdevtodayjason/titanium-plugins`**. If there are internal team
plugins there a new dev should get, add it too:
```text
/plugin marketplace add webdevtodayjason/titanium-plugins
# then /plugin install <plugin>@titanium-plugins
```

---

## TL;DR — full setup for a new dev

1. Install dev-kit (see [README](README.md)) → skills, commands, agents, conventions.
2. From this file, install the plugins you need: **claude-mem** + **CodeRabbit** +
   **Codex** + **Ralph Wiggum** (swift-lsp only for Swift work).
3. Add MCPs with your own creds: **Linear**, **ghost.build** (context7 is already in).
4. Restart Claude Code and run `/context-audit` to confirm everything loaded.

*Part of the [dev-kit](https://github.com/webdevtodayjason/dev-kit) onboarding toolkit.*
