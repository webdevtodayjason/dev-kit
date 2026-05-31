---
description: Run a comprehensive code review for quality, security, and maintainability
---

# Code Review

Conduct a thorough code review with severity-rated feedback.

## Procedure

1. **Identify Changes**
   - Run `git diff` (or `git diff HEAD` for staged) to find changed files
   - Determine scope of review

2. **Launch Three Review Agents in Parallel** using the Agent tool:

   **Agent 1: Security Review**
   - Hardcoded secrets, injection risks, XSS, CSRF
   - OWASP Top 10 checklist
   - Dependency vulnerabilities (`npm audit`)

   **Agent 2: Code Quality Review**
   - Function size, complexity, nesting depth
   - Duplication (DRY violations)
   - Naming, documentation, error handling
   - Coupling, testability, maintainability

   **Agent 3: Performance Review**
   - Algorithm efficiency, N+1 queries
   - Caching opportunities
   - Unnecessary re-renders (React)
   - Memory leaks, unbounded growth

3. **Severity Rating**
   - **CRITICAL** — Security vulnerability (must fix before merge)
   - **HIGH** — Bug or major code smell (should fix before merge)
   - **MEDIUM** — Minor issue (fix when possible)
   - **LOW** — Style/suggestion (consider fixing)

4. **Output Format**
   ```
   CODE REVIEW REPORT
   ==================
   Files Reviewed: N
   Total Issues: N

   CRITICAL (N)
   HIGH (N)
   MEDIUM (N)
   LOW (N)

   [Each issue: file:line, description, fix recommendation]

   RECOMMENDATION: APPROVE / REQUEST CHANGES / COMMENT
   ```

5. **Fix Issues** — Aggregate findings from all three agents and fix directly. Skip false positives.
