---
description: "False positive suppressions for the QA pipeline. Add entries to skip known non-issues."
---

# False Positive Suppressions

When the QA pipeline flags something that your team has reviewed and determined is not a real issue, add it here. The pipeline checks this file and skips matching findings.

## How to Add a Suppression

Add one entry per line in the Suppressions section below. Each entry has:
- A **pattern** -- a short description that matches the finding (fuzzy matching)
- A **reason** -- why this is not a real issue

## Suppressions

<!-- Add entries below. Format:
- "pattern description" -- reason this is not a real issue

Examples:
- "console.log in src/lib/n8n/" -- intentional debug logging for webhook route debugging
- "missing auth on /api/health" -- public health check endpoint, no auth needed by design
- "hardcoded URL in src/config/endpoints.ts" -- these are public API base URLs, not secrets
-->
