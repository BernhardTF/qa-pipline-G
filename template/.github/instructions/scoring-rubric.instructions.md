---
description: "Confidence scoring guide for QA findings. Defines the 0-100 scale and 75+ inclusion threshold."
---

# Confidence Scoring Rubric

Every finding from a specialist agent is scored 0-100 for confidence. Only findings scoring **75 or above** are included in the final report.

## Scoring Scale

These are anchor points. Agents may use any integer 0-100 -- intermediate scores (e.g., 60, 85, 90) are valid when a finding falls between two anchors.

| Score | Label | Criteria |
|-------|-------|----------|
| **0** | False positive | Does not stand up to light scrutiny. Pre-existing issue not introduced by this diff. Or simply wrong. |
| **25** | Uncertain | Might be a real issue, but could also be a false positive. Agent could not verify it. If stylistic, no explicit project rule supports the claim. |
| **50** | Possible | Verified as a real issue, but it's a nitpick or unlikely to cause problems in practice. Low importance relative to the rest of the diff. |
| **75** | Likely (threshold) | Double-checked and very likely a real issue that will be hit in practice. Important -- directly impacts functionality, or violates an explicit rule. **This is the minimum score to appear in the report.** |
| **100** | Certain | Absolutely confirmed. Evidence directly proves this is a real issue. Will happen frequently. Cannot be dismissed. |

## Scoring Guidelines

### Score 75+ (INCLUDE in report)
- The finding is verified against actual code, not hypothetical
- The issue will materially affect the application (security, correctness, crashes)
- The finding cites a specific rule from CLAUDE.md, rubrics, or current library documentation
- The agent can point to the exact line(s) and explain why they are wrong

### Score Below 75 (EXCLUDE from report)
- The finding is speculative ("this might cause issues")
- The issue is stylistic without an explicit project rule
- The issue is something a linter, typechecker, or compiler would catch
- The finding is about code that was not changed in this diff
- The "fix" is subjective and the current approach is equally valid

## Cross-Check Against Suppressions

After scoring, check each finding against the false-positive suppressions file. If a finding matches a suppression entry, reduce its score to 0 regardless of initial score.

## Deduplication

If multiple agents flag the same issue (same file, same line, same problem), keep only the highest-scored version.
