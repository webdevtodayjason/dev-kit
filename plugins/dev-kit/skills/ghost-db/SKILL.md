---
name: ghost-db
description: >-
  Ephemeral, forkable Postgres databases via ghost.build — the
  agent-native database service. Use this skill when the user needs:
  a throwaway Postgres for testing, a safe fork of an existing
  database to experiment against without polluting state, an
  isolated DB per agent task, or any work that benefits from
  "create-fork-discard freely" semantics.

  Triggers: user says "ghost create", "fork the database", "spin up
  a Postgres", "I need a test DB", "give me a database for this
  agent", "ghost.build", or describes a scenario that would otherwise
  require a Docker postgres container + manual setup + manual teardown.

  The CLI lives at `~/.local/bin/ghost`. MCP tools are also available
  (install via `ghost mcp install`) and are the preferred surface for
  in-conversation database operations.
---

# Ghost — Agent-Native Postgres

Ghost.build is the first database service designed for AI agents: unlimited Postgres databases you can create, fork, and discard freely. The pricing model (100 hrs/mo free, 1TB storage free, hard spending caps) makes it economically feasible to spin up disposable databases per agent task — something that's prohibitive on traditional managed Postgres.

Use this skill when the user needs Postgres for any non-production purpose where ephemerality + isolation matter more than long-lived persistence.

## When to invoke this skill

### Strong triggers (always invoke)
- "ghost create" / "ghost fork" / "ghost.build" / "ghost CLI" mentions
- "I need a test database" / "give me a throwaway Postgres"
- "Fork the staging DB so I can test without breaking it"
- "Run this migration on a copy first"
- "Each agent task should get its own database"

### Soft triggers (consider invoking)
- User describes a flow that creates throwaway test data in a shared DB and worries about cleanup
- Multi-tenant testing scenarios where per-tenant DB isolation is wanted
- Quality-gate / smoke-test scenarios that need a known-good DB state
- "How do I test this without polluting prod?"
- Database migration validation work

### When NOT to use Ghost
- Production data. Ghost is for **non-production** workloads — explicitly designed for ephemerality.
- Long-lived persistence with audit/compliance requirements (use a real managed Postgres SKU)
- Workloads needing very low p99 latency at scale (Ghost optimizes for spin-up speed, not max throughput)

## Setup verification

Before using Ghost, confirm install + auth:

```bash
ghost --help                  # CLI present
ghost login                   # GitHub OAuth (one-time)
ghost mcp install             # Install MCP server (one-time)
ghost list                    # Should show existing databases or "none"
```

If `ghost` isn't on PATH: `curl -fsSL https://install.ghost.build | sh`

## CLI quick reference (most-used)

| Command | What it does |
|---|---|
| `ghost create [name]` | Create a new Postgres DB |
| `ghost fork <source> [new-name]` | Fork an existing DB |
| `ghost list` | List all databases |
| `ghost connect <name>` | Get connection string |
| `ghost psql <name>` | Open `psql` shell against the DB |
| `ghost sql <name> "<query>"` | Run one-shot SQL |
| `ghost schema <name>` | Display schema |
| `ghost share <name>` | Share a DB (read-only by default) |
| `ghost pause <name>` / `resume <name>` | Stop / start (saves compute hours) |
| `ghost delete <name>` | Permanently delete |
| `ghost status` | Show usage (hours, storage) |

Full reference: `ghost help` or https://ghost.build/docs/#cli-reference

## MCP tools (preferred for in-conversation work)

When the MCP server is installed (`ghost mcp install`), Claude can drive Ghost directly through MCP rather than shelling out. Available tools include:

- `ghost_create`, `ghost_create_dedicated` — provision a DB
- `ghost_fork`, `ghost_fork_dedicated` — fork an existing DB
- `ghost_list`, `ghost_delete`, `ghost_rename` — lifecycle
- `ghost_connect`, `ghost_psql` — connection info
- `ghost_sql` — run SQL queries directly
- `ghost_schema` — introspect schema
- `ghost_logs`, `ghost_status` — observability
- `ghost_pause`, `ghost_resume` — cost optimization
- `ghost_share`, `ghost_share_list`, `ghost_share_revoke` — sharing
- `ghost_invoice`, `ghost_invoice_list` — billing

Plus useful prompts for common Postgres patterns:
- `design-postgres-tables`, `design-postgis-tables`
- `setup-timescaledb-hypertables`
- `find-hypertable-candidates`, `migrate-postgres-tables-to-hypertables`
- `pgvector-semantic-search`, `postgres-hybrid-text-search`

Inspect a specific capability: `ghost mcp get <tool-name>`

## Common workflows

### Fork-then-Test (the killer pattern)

Instead of running tests against a shared dev/staging DB (which pollutes state and requires cleanup), fork it per test run:

```bash
# Source DB exists (e.g. my-staging-db)
ghost fork my-staging-db   test-run-1
ghost connect test-run-1    # use this URL in tests
# ... run tests / migration trial ...
ghost delete test-run-1     # zero cleanup; the fork is gone
```

No `--teardown` script. No "did I miss a row?" anxiety. The fork was real Postgres with all the source data; discarding it deletes everything atomically.

### Ephemeral DB per agent task

When dispatching workers that need their own DB state:

```bash
# At worker dispatch:
DB_NAME="agent-task-$(date +%s)"
ghost create $DB_NAME
ghost connect $DB_NAME    # pass URL to worker as env var

# In worker prompt: "Your DATABASE_URL is X. You may DROP/CREATE freely.
#                   The DB will be deleted at task completion."

# After verify:
ghost delete $DB_NAME
```

### Schema-design with LLM assistance

Ghost's MCP server exposes prompts (`design-postgres-tables`, `pgvector-semantic-search`, etc.) that pair the LLM with live DB access. Use these when designing new schemas to iterate quickly:

```
ghost create scratch
ghost mcp     # Then in Claude: use the design-postgres-tables prompt against scratch
# Iterate on table shapes; test against the live DB
# Promote final schema to a real DB; delete scratch
```

### Validating a migration before running on real data

```bash
ghost fork prod-replica migration-test
# Apply the migration to the fork
psql $(ghost connect migration-test) -f migration.sql
# Run smoke queries / data integrity checks
# If broken: ghost delete migration-test, iterate. If green: apply to prod.
```

## Cost notes

- **100 compute-hours / month free**, **1 TB storage free**, hard spending caps (no surprise bills)
- Compute-hours accrue only when the DB is **running** — `ghost pause` stops the clock without deleting
- Forks share storage with the source until divergent writes (copy-on-write); cheap to fork
- Use `ghost status` to monitor usage
- For long-lived dev databases that don't need to be online, `pause` aggressively

## Safety / hygiene

- **Never fork a production DB into Ghost without reviewing the data sensitivity.** Ghost is hosted infrastructure, not customer infra. PII in a fork is PII in Ghost. Use Ghost for non-PII / synthetic data, or use a managed Postgres SKU inside your own VPC for sensitive forks.
- Use `ghost share` carefully — shares are URL-keyed; revoke when done (`ghost share revoke`)
- `ghost delete` is **permanent**. Add a confirmation step in scripts.
- API keys (`ghost api-key`) are bearer tokens — treat like passwords; store in env vars, never commit

## Quick decision tree

When the user describes a database need:

1. **Is it production?** → No Ghost. Recommend managed Postgres (RDS, Cloud SQL, Crunchy Bridge, etc.)
2. **Is it short-lived / disposable?** → ✅ Ghost is the right answer
3. **Do they need to fork existing data?** → ✅ Ghost (`ghost fork`)
4. **Is it for one agent task that should clean up after itself?** → ✅ Ghost (create + delete pattern)
5. **Do they need pgvector / TimescaleDB / specialty extensions?** → Check `ghost mcp get` for available templates; if supported, ✅ Ghost
6. **Are they on a budget?** → 100 hrs/mo free is generous; Ghost wins on cost for most non-prod cases

## Cross-reference

- Official docs: https://ghost.build/docs/
- Tutorials: https://ghost.build/tutorials/
- Built-with-Ghost showcase: https://ghost.build/built-with-ghost.html
