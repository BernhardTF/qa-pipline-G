# /qa-fixit -- Fix QA Review Findings

You fix code issues identified by the QA review pipeline and update the review report to reflect what was fixed.

## Step 1: Find the Latest Report

Look for the most recent file in `.review/reports/` (sorted by filename, which is a timestamp).

If no reports exist:
```
No review reports found. Run /qa first to review your changes.
```
And stop.

Read the report. If the verdict is PASS:
```
Latest review is already PASS. Nothing to fix.
```
And stop.

## Step 2: Parse Findings

Extract all findings from the report. Only include findings with severity **BLOCK** or **WARN**. Skip INFO findings (those are optional suggestions, not actionable fixes).

For each finding, extract:
- Severity (BLOCK or WARN)
- Title
- Agent that found it
- File path and line number
- Issue description
- Fix recommendation
- Confidence score

## Step 3: Create Fix Plan

Order findings by severity (BLOCK first, then WARN) and by file (group fixes in the same file together to minimize line-shift conflicts).

Display the batch plan:

```
## QA Fix Plan

Found {N} issues to fix from report {timestamp}:

  1. [BLOCK] Missing auth check          src/app/api/leads/route.ts:14
  2. [BLOCK] SQL injection risk           src/lib/db/queries.ts:87
  3. [WARN]  Unhandled null               src/hooks/use-campaigns.ts:23
  4. [WARN]  Missing await                src/app/api/calls/route.ts:41
  5. [WARN]  Wrong Drizzle API usage      src/lib/db/queries.ts:102

Apply all fixes? (y/n)
```

Wait for confirmation. If the developer says no, stop.

## Step 4: Apply Fixes in Batch

Process findings in the order shown (BLOCK first, grouped by file). For each finding:

### 4a. Read the Current Code
Read the file at the specified line. Look at surrounding context (at least 10 lines before and after) to understand the code.

### 4b. Apply the Fix
Use the fix recommendation from the report as guidance. Apply the fix using the edit tool. The fix must:
- Solve the specific issue described
- Not introduce new issues
- Match the project's coding patterns (read CLAUDE.md if needed)
- Be minimal -- fix the issue, don't refactor surrounding code

### 4c. Record the New Line Reference
After applying the fix, note the new line number where the fixed code now lives. Line numbers shift as you edit, so read the file again if needed to confirm.

### 4d. Handle Fix Failures
If a finding cannot be fixed automatically (too complex, ambiguous, requires design decision):
- Note the reason
- Continue to the next finding

## Step 5: Update the Review Report

Read the original report file. Create an updated version with these changes:

### 5a. Update Frontmatter
Add fix metadata to the YAML frontmatter:
```yaml
fixed_date: {ISO 8601 timestamp}
fixed_count: {number of findings fixed}
skipped_count: {number of findings skipped}
original_verdict: {original verdict}
updated_verdict: {new verdict after fixes}
```

### 5b. Update Each Finding
For each finding that was fixed, update its entry:

Change:
```
### 1. [BLOCK] Missing auth check
**Agent:** qa-security | **Confidence:** 85/100
**File:** `src/app/api/leads/route.ts:14`
```

To:
```
### 1. [FIXED] ~~Missing auth check~~
**Agent:** qa-security | **Confidence:** 85/100
**Original:** `src/app/api/leads/route.ts:14`
**Fixed at:** `src/app/api/leads/route.ts:16`
**Status:** Fixed by /qa-fixit
```

For skipped findings, change severity to [SKIPPED] and add the reason.

### 5c. Update Verdict
Recalculate the verdict based on remaining unfixed findings:
- All findings fixed -> **PASS (fixed)**
- Only WARN findings remain unfixed -> **WARN**
- BLOCK findings remain unfixed -> **BLOCK**

### 5d. Add Fix Summary
Append a summary section at the bottom of the report:

```
---

## Fix Summary

**Fixed by:** /qa-fixit
**Date:** {timestamp}
**Results:** {fixed_count} fixed, {skipped_count} skipped

| # | Finding | Status | Original Line | Fixed Line |
|---|---------|--------|---------------|------------|
| 1 | Missing auth check | FIXED | route.ts:14 | route.ts:16 |
| 2 | SQL injection risk | FIXED | queries.ts:87 | queries.ts:89 |
| 3 | Unhandled null | SKIPPED | use-campaigns.ts:23 | -- |
```

### 5e. Write the Updated Report
Overwrite the original report file with the updated version. Do NOT create a new report file -- update in place so the audit trail stays clean.

## Step 6: Final Output

```
## QA Fix Complete

**Fixed:** {count}
**Skipped:** {count} (require manual attention)
**Updated verdict:** {PASS (fixed) | WARN | BLOCK}

Report updated: .review/reports/{filename}

{If all fixed:}
Code is ready to commit.

{If skipped findings remain:}
Skipped findings need manual attention:
  - {finding title}: {skip reason}
```

## Important Rules

- ALWAYS get confirmation before applying fixes. Never silently edit source code.
- Fix BLOCK findings first, then WARN. Skip INFO entirely.
- Group fixes by file to minimize line-shift problems.
- After editing a file, re-read it to get accurate new line numbers.
- Do NOT refactor, optimize, or improve code beyond what the finding asks for.
- Do NOT create new files. Only edit existing files to fix specific findings.
- If a fix is ambiguous or risky, SKIP it rather than guessing.
- Update the report even if some findings were skipped.
