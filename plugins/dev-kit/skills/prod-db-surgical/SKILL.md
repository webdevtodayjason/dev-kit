---
name: prod-db-surgical
description: >-
  Hard rules for working with a production database. Triggers when the user
  says "production database", "prod database", "prod DB", "live database", or
  when any database-modifying command
  (`prisma db push`, `prisma migrate`, `ALTER`, `DROP`, `UPDATE`, `DELETE`,
  `CREATE INDEX`, etc.) is being considered against a `DATABASE_URL` that
  resolves to production.

  Encodes the hard lesson that a stale-branch
  `prisma db push --accept-data-loss` can silently drop a column with live data.
  This skill prevents that pattern from recurring by mandating
  surgical, single-statement, idempotent SQL with explicit per-operation
  confirmation for anything destructive.
---

# Production Database — Surgical Operations Only

A production database is one row, one query, one column-change away from
unrecoverable damage. Stale branches, smart-looking flags, and "this is
additive, safe" assumptions are how that damage happens. This skill exists to
slow down JUST enough to never repeat that kind of incident.

## Core principle

**Every prod-DB modification is one explicit SQL statement, reviewed before it
runs.** Not "a Prisma push that figures it out." Not "the schema is already
correct, just sync it." A single `ALTER` / `INSERT` / `UPDATE` / `DELETE`,
written down, shown to the user, executed as that exact statement.

## The hard rules

### 1. Never run these against prod without explicit per-operation approval

| Forbidden by default | Why |
|---|---|
| `prisma db push` | Reconciles ENTIRE local schema against the DB. If the local schema is stale or branched from an older base, every diff is silently applied. The project's `package.json` scripts often have `--accept-data-loss` baked in, which makes destructive drops happen without prompting. |
| `prisma migrate dev` | Generates and applies migrations. Touches the DB even in "dev" mode if `DATABASE_URL` points at prod. |
| `prisma migrate deploy` | Applies pending migrations. Acceptable ONLY when the migration was generated against a known-clean dev DB and reviewed. |
| `--accept-data-loss` flag | Never. If destruction is required, run the destructive SQL surgically as a separate step. |
| `DROP TABLE`, `DROP COLUMN`, `ALTER ... DROP`, `TRUNCATE` | Each requires explicit user confirmation in chat for that exact statement. |
| `UPDATE` / `DELETE` without `WHERE` | Reject categorically. Even "I want to clear all X" goes via a per-row review. |
| `UPDATE` / `DELETE` with `WHERE` matching > 1 row | Confirm row count first via a `SELECT COUNT(*)` with the same WHERE; show the user. |

### 2. Branch-base check before ANY prod-DB-touching command

Before running anything against prod:

1. Check the current local schema is what the user thinks it is:
   ```bash
   git rev-parse HEAD
   git log --oneline origin/main..HEAD
   git log --oneline HEAD..origin/main
   ```
2. If the local branch is missing commits from `origin/main`, STOP. The local schema is stale. A `db push` from a stale branch will roll the prod schema BACKWARD, dropping columns/tables that recent merges added.
3. Surface the staleness to the user. Recommend rebasing first, OR using the surgical alternative below (which doesn't depend on local schema).

### 3. Prefer surgical raw SQL over schema diff

For single-column / single-index / single-row changes, write the exact SQL and execute it directly. Do NOT use `prisma db push` or `prisma migrate`.

**Use `prisma db execute --stdin --url $DATABASE_URL`** (built into the project, reads SQL from stdin):

```bash
echo 'ALTER TABLE "Document" ADD COLUMN IF NOT EXISTS "renderedHtml" TEXT;' \
  | npx prisma db execute --stdin --url "$DATABASE_URL"
```

This:
- Touches ONLY the named table/column
- Has no schema-diff side effects
- Doesn't need `--accept-data-loss`
- Is idempotent if you use `IF NOT EXISTS` / `IF EXISTS`

If `psql` is installed locally that also works; the `prisma db execute --stdin` path works without any external CLI.

### 4. Idempotency clauses are mandatory

Every DDL statement gets:

- `CREATE TABLE IF NOT EXISTS`
- `CREATE INDEX IF NOT EXISTS`
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- `DROP TABLE IF EXISTS` (when authorized)
- `DROP INDEX IF EXISTS`

So the same SQL is safe to re-run if the first execution hung or partially failed.

### 5. Verify the change took effect

After ANY prod-DB write, run a verification query that depends on the modified surface. Don't trust "Script executed successfully" — that just means the connection worked.

For a column add, query the column:
```bash
npx tsx -e "
import { PrismaClient } from '@prisma/client';
const p = new PrismaClient();
p.document.findFirst({ select: { id: true, renderedHtml: true } })
  .then(r => console.log('✅', r))
  .catch(e => { console.error('❌', e.message); process.exit(1); })
  .finally(() => p.\$disconnect());
"
```

For an index add, run an `EXPLAIN` on a query that should use it. For a row update, re-`SELECT` the row and confirm the new value.

### 6. Backup check before destructive operations

Before any operation that COULD lose data (DROP, ALTER COLUMN with type change, UPDATE/DELETE matching > 0 rows, schema rollback):

1. Confirm the provider's automated backups cover this DB and are recent
   - Railway: dashboard → service → Backups (paid tier has automated; free tier may not)
   - Supabase: dashboard → Database → Backups
   - Self-hosted: check the cron / script writing to S3/disk
2. Surface the latest backup timestamp to the user
3. Get explicit per-operation approval

If the backup check is unclear, halt and surface the gap. Do NOT proceed with the assumption that backups exist.

### 7. Single statement per execution

Don't bundle "add column AND drop table AND modify enum" into one stdin payload. One statement per command. Each verified independently. Easier to roll back, easier to debug if one fails mid-batch.

### 8. Document every prod-DB change

After execution, write to a durable runbook (whichever this project uses):
- `ORCHESTRATION.md` for active orchestrator sessions
- `ops/runbooks/prod-db-changes.md` if the project has one
- A new entry in `lib/changelog.ts` if the change is user-visible

Each entry: timestamp, what changed, the exact SQL run, who authorized, the verify result. So six months from now, when someone asks "when did this column appear", it's answerable.

## Decision tree when asked to do a prod-DB operation

```
Is this against prod (DATABASE_URL points at production)?
├── No → normal dev rules apply, this skill doesn't bind
└── Yes
    ├── Is the request a `prisma db push` or `prisma migrate`?
    │   └── REFUSE by default. Counter-propose the surgical equivalent.
    │       Only proceed with explicit user override after surfacing the risk.
    │
    ├── Is it surgical raw SQL (single ALTER/INSERT/UPDATE/SELECT)?
    │   ├── Read-only (SELECT, EXPLAIN, \d): execute freely
    │   ├── Additive (ADD COLUMN, CREATE INDEX, INSERT new row): write
    │   │   the SQL with IF NOT EXISTS, show to user, execute on go-ahead
    │   └── Destructive (DROP, UPDATE, DELETE, ALTER ... DROP):
    │       1. Run the equivalent SELECT to show what's about to be touched
    │       2. Show the user the SQL + the affected row count + the backup
    │          status
    │       3. Wait for explicit per-operation chat confirmation
    │       4. Execute. Verify. Document.
    │
    └── Is the local working tree clean and on a known commit relative to
        origin/main?
        ├── Yes → proceed
        └── No → surface the staleness; the user must confirm the
            mismatch is intentional before any DB write
```

## Anti-patterns to call out by name

When the user (or another agent) suggests these, refuse and counter-propose:

- **"It's just a schema sync, prisma db push is fine"** → No. Use raw SQL.
- **"The change is additive, no risk"** → Verify by writing the exact SQL.
  Don't trust the framing.
- **"Use --accept-data-loss, the table is empty"** → Drop the table
  surgically: `DROP TABLE IF EXISTS "Foo";` after confirming row count.
  Don't conflate "accept-data-loss" with "no data to lose".
- **"It worked locally, push to prod"** → Local DB and prod DB diverge in
  ways your local tests don't cover (rows, indexes, extensions, perms).
  Always surgical.
- **"I'll create a migration to handle it"** → Migrations are for
  versioned schema evolution with code review. For one-shot fixes,
  surgical SQL is faster and clearer.

## What this skill never does

- Run prod-DB operations autonomously without per-operation user approval
- Trust `--accept-data-loss` to mean "no real data"
- Assume a branch is up to date; always check
- Skip the verify step
- Skip documentation

## Trigger phrases (what gets you here)

- "production database", "prod database", "prod DB"
- "live database"
- The user pointing at a `DATABASE_URL` env value clearly tied to prod
- Any `prisma db push` / `prisma migrate` / `ALTER`/`DROP`/`UPDATE`/`DELETE`
  command being considered for execution against an unknown DB — verify it's
  not prod before proceeding; if prod, this skill applies

When this skill activates, the next response to the user states:

> Operating under prod-DB-surgical rules. Single-statement, idempotent SQL.
> Explicit per-operation approval for anything destructive. Show SQL before
> execute. Verify after. Document on completion.

…then proceed within those rules.
