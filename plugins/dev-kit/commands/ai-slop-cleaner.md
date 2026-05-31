---
description: Run an anti-slop cleanup/refactor/deslop workflow on changed code
---

# AI Slop Cleaner

Reduce AI-generated slop with a regression-tests-first, smell-by-smell cleanup workflow that preserves behavior and raises signal quality.

## Procedure

1. **Lock behavior with regression tests first**
   - Identify the behavior that must not change
   - Add or run targeted regression tests before editing cleanup candidates
   - If behavior is currently untested, create the narrowest test coverage needed first

2. **Create a cleanup plan before code**
   - Run `git diff` to identify changed files
   - List the specific smells to remove
   - Order fixes from safest/highest-signal to riskiest
   - Do not start coding until the cleanup plan is explicit

3. **Categorize issues before editing**
   - **Duplication** — repeated logic, copy-paste branches, redundant helpers
   - **Dead code** — unused code, unreachable branches, stale flags, debug leftovers
   - **Needless abstraction** — pass-through wrappers, speculative indirection, single-use helper layers
   - **Boundary violations** — hidden coupling, leaky responsibilities, wrong-layer imports
   - **Missing tests** — behavior not locked, weak regression coverage

4. **Execute passes one smell at a time**
   - Pass 1: Dead code deletion
   - Pass 2: Duplicate removal
   - Pass 3: Naming/error handling cleanup
   - Pass 4: Test reinforcement
   - Re-run build/lint after each pass. Avoid bundling unrelated refactors.

5. **Run quality gates**
   - Build passes (`npx next build` or equivalent)
   - Lint passes
   - Diff stays minimal and scoped
   - No new abstractions or dependencies unless explicitly required

6. **Report**
   ```
   AI SLOP CLEANUP REPORT
   ======================
   Scope: [files]
   Passes Completed: [list]
   Quality Gates: build PASS/FAIL, lint PASS/FAIL
   Changed Files: [list with simplifications]
   Remaining Risks: [deferred items]
   ```
