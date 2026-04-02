---
description: "OWASP-based security checklist for the qa-security agent. Stack-agnostic defaults with a section for project-specific items."
---

# Security Review Checklist

## BLOCK Severity (Must Fix)

### Hardcoded Secrets
- API keys, tokens, passwords, or connection strings in source code
- Secrets in comments, variable names, or string literals
- Private keys or certificates committed to repo
- `.env` files or credential files not in .gitignore
- Look for patterns: `sk-`, `ghp_`, `AKIA`, `password=`, `secret=`, `token=`, `apiKey=`

### SQL / NoSQL Injection
- String interpolation or concatenation in database queries
- User input passed directly to raw query methods
- Template literals in SQL without parameterization
- Dynamic query construction from request parameters

### Command Injection
- User input in shell commands (exec, spawn, system, os.system, subprocess)
- Unsanitized input in child_process calls
- Template literals in command strings with external data

### Authentication Bypass
- API routes / endpoints without authentication checks
- Missing authorization checks (user can access other users' data)
- Broken session management
- JWT validation missing or using weak algorithms

### Cross-Site Scripting (XSS)
- Unescaped user input rendered in HTML
- Use of `dangerouslySetInnerHTML`, `innerHTML`, `v-html` with user data
- Reflected input in error messages or URLs

## WARN Severity (Should Fix)

### Server-Side Request Forgery (SSRF)
- User-controlled URLs passed to fetch/axios/http without validation
- Missing URL allowlist for external requests

### Path Traversal
- User input in file paths without sanitization
- `../` sequences not stripped from path parameters

### Insecure Deserialization
- Deserializing untrusted data into executable context
- YAML.load with unsafe loader

### Sensitive Data in Logs
- Passwords, tokens, or PII in console.log / logger calls
- Full request bodies logged including auth headers

### Missing Security Headers
- No Content-Security-Policy
- Missing CORS restrictions (Access-Control-Allow-Origin: *)

## INFO Severity (Consider)

### Rate Limiting
- Public endpoints without rate limiting
- Auth endpoints without brute-force protection

### Error Information Disclosure
- Detailed error messages in production responses
- Database error details exposed to clients

---

## Stack-Specific Items

<!-- Run qa-init to populate this section based on your detected stack -->
