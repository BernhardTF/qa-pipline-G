---
name: qa
description: Run multi-agent QA review on current code changes before committing. Use when the user says "review my code", "qa check", "run qa", or types /qa.
---

# /qa -- Multi-Agent QA Review

Delegate to the `qa-orchestrator` agent to run the full review pipeline. Pass the user's request as-is. The orchestrator handles everything: gathering the diff, spawning 4 specialist agents (security, correctness, patterns, API docs), scoring findings, and outputting the verdict.

If the user specifies particular files or a scope, pass that along. Otherwise the orchestrator reviews all uncommitted changes.
