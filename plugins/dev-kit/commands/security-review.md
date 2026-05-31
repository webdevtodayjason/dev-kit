---
description: Run a comprehensive security audit on code changes
---

# Security Review

Conduct a thorough security audit checking for OWASP Top 10 vulnerabilities, hardcoded secrets, and unsafe patterns.

## Procedure

1. **Scope** — Run `git diff` to identify changed files, or review specified files

2. **OWASP Top 10 Scan**
   - A01: Broken Access Control
   - A02: Cryptographic Failures
   - A03: Injection (SQL, NoSQL, Command, XSS)
   - A04: Insecure Design
   - A05: Security Misconfiguration
   - A06: Vulnerable and Outdated Components
   - A07: Identification and Authentication Failures
   - A08: Software and Data Integrity Failures
   - A09: Security Logging and Monitoring Failures
   - A10: Server-Side Request Forgery (SSRF)

3. **Secrets Detection**
   - Hardcoded API keys, passwords, tokens
   - Private keys in repo
   - Connection strings with secrets
   - Grep for patterns: `sk_`, `api_key`, `password`, `secret`, `token`

4. **Input Validation**
   - All user inputs sanitized
   - SQL/NoSQL injection prevention
   - XSS prevention (output escaping)
   - Path traversal prevention

5. **Authentication/Authorization**
   - Proper password hashing
   - Session management security
   - Access control enforcement
   - JWT implementation security

6. **Dependency Security**
   - Run `npm audit` for known vulnerabilities
   - Check for outdated dependencies with critical CVEs

7. **Output Format**
   ```
   SECURITY REVIEW REPORT
   ======================
   Scope: [files scanned]

   CRITICAL (N) — must fix immediately
   HIGH (N) — fix before deploy
   MEDIUM (N) — fix when possible
   LOW (N) — best practice suggestions

   [Each finding: file:line, description, impact, remediation, OWASP reference]

   DEPENDENCY VULNERABILITIES: [npm audit results]

   OVERALL ASSESSMENT: [PASS / FAIL]
   RECOMMENDATION: [DEPLOY / DO NOT DEPLOY]
   ```

## Severity Definitions
- **CRITICAL** — Exploitable vulnerability (data breach, RCE, credential theft)
- **HIGH** — Vulnerability with serious impact under specific conditions
- **MEDIUM** — Security weakness with limited impact
- **LOW** — Best practice violation or minor concern
