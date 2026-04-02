---
description: "Master review contract for the QA pipeline. Defines severity levels, review scope, and false positive guidance."
---

# QA Review Rules

This is the master review contract for the QA pipeline. All specialist agents follow these rules.

## Severity Definitions

| Severity | Label | Meaning | Action |
|----------|-------|---------|--------|
| BLOCK | Must fix | Security vulnerability, data loss risk, crash, auth bypass | Cannot commit until resolved |
| WARN | Should fix | Bug, logic error, missing error handling, bad pattern | Fix before merge; commit is allowed |
| INFO | Consider | Minor improvement, style deviation, optimization opportunity | Optional; logged but not blocking |

## What To Review

Focus only on code that was **changed in the diff**. Do not review pre-existing code unless the change introduces a new interaction with it that creates a problem.

### Review Dimensions (in priority order)
1. **Security** -- injection, secrets, auth, OWASP Top 10
2. **Correctness** -- logic errors, edge cases, null/undefined, error handling
3. **Pattern Compliance** -- project conventions from CLAUDE.md and pattern rubrics
4. **API Usage** -- library APIs used correctly per current documentation

## What NOT To Review

Do not flag any of the following:
- **Style/formatting** -- linters and formatters handle this
- **Test coverage** -- separate concern; do not comment on missing tests unless a CLAUDE.md rule requires them
- **Pre-existing issues** -- only review lines that were actually changed
- **Linter-catchable issues** -- type errors, unused imports, missing semicolons
- **Generated/vendored code** -- skip files in generated/, vendor/, node_modules/, migrations/
- **Subjective preferences** -- if there's no explicit rule and both approaches are valid, do not flag it
- **Documentation gaps** -- unless a CLAUDE.md rule explicitly requires docs for the changed code

## False Positive Guidance

A finding is a false positive if:
- The code was not modified in this diff (pre-existing)
- The issue would be caught by a linter, typechecker, or compiler
- It's a subjective style preference without an explicit project rule
- The pattern is intentionally different and there's a code comment explaining why
- The "issue" is actually a feature or intentional behavior change
- It contradicts the project's established patterns (the project's patterns win)

## Output Constraints

- Maximum **7 detailed findings** in the report
- Every finding must include: severity, file:line, description, evidence, and which agent found it
- Findings must be **actionable** -- tell the developer what's wrong AND how to fix it
