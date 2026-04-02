---
name: qa-init
description: Initialize the QA review pipeline for the current project. Detects tech stack, reads CLAUDE.md conventions, uses Context7 to research best practices, and scaffolds a .review/ directory with customized rubric files. Run once per project.
---

# /qa-init -- Initialize QA Review Pipeline

You are the QA pipeline initializer. Set up the `.review/` directory for the current project so that the QA review agents can provide project-specific reviews.

## Step 1: Check If Already Initialized

Check if `.review/` directory already exists:
- If it exists and contains files, ask: "`.review/` already exists. Reinitialize? (false-positive-suppressions.md will be preserved)"
- If user says no, stop.

## Step 2: Detect Tech Stack

Check for project manifest files:

### JavaScript / TypeScript
Read `package.json`. Extract:
- **Framework**: next, react, vue, angular, express, fastify, hono
- **ORM/DB**: drizzle-orm, prisma, typeorm, sequelize, mongoose
- **Validation**: zod, yup, joi, valibot
- **State**: @tanstack/react-query, redux, zustand, jotai
- **Auth**: next-auth, @auth/core, passport, lucia
- **UI**: tailwindcss, class-variance-authority, @radix-ui
- **TypeScript**: check for tsconfig.json

### Python
Read `pyproject.toml` or `requirements.txt`. Detect: django, flask, fastapi, sqlalchemy, pydantic, pytest.

### Go
Read `go.mod`. Detect: gin, echo, fiber, chi, gorm, ent.

### Rust
Read `Cargo.toml`. Detect: actix-web, axum, rocket, warp.

Report what was detected.

## Step 3: Read CLAUDE.md Conventions

If `CLAUDE.md` exists, extract: coding standards, architecture patterns, file structure, explicit rules.

## Step 4: Context7 Research

For the top 3-5 detected libraries, query Context7:
1. `context7/resolve-library-id` for each library
2. `context7/query-docs` for "common security mistakes and pitfalls"

Collect findings to enrich rubrics. Max 6 Context7 calls total.

## Step 5: Create .review/ Directory

```bash
mkdir -p .review
```

Create each rubric file:

**REVIEW_RULES.md** -- Copy from `.github/instructions/review-rules.instructions.md` as-is.

**security-checklist.md** -- Start from `.github/instructions/security-checklist.instructions.md`, append a Stack-Specific Items section from Context7 research.

**pattern-conventions.md** -- Start from `.github/instructions/pattern-conventions.instructions.md`, fill in each section from CLAUDE.md analysis. For sections without CLAUDE.md guidance, add: "No explicit convention found. Add your team's convention here."

**false-positive-suppressions.md** -- Copy from `.github/instructions/false-positives.instructions.md`. If reinitializing, PRESERVE existing entries.

**scoring-rubric.md** -- Copy from `.github/instructions/scoring-rubric.instructions.md` as-is.

## Step 6: Report

```
## QA Pipeline Initialized

**Stack detected:** {summary}
**Libraries researched via Context7:** {list}

**Files created in .review/:**
- REVIEW_RULES.md
- security-checklist.md (customized for {stack})
- pattern-conventions.md (populated from CLAUDE.md)
- false-positive-suppressions.md (empty)
- scoring-rubric.md

**Next step:** Run /qa to review your current changes.
```

## Important Rules

- Do NOT create files outside of `.review/`.
- Do NOT modify CLAUDE.md or any other project files.
- Do NOT add `.review/` to .gitignore -- these files should be version-controlled.
- Preserve existing `false-positive-suppressions.md` entries on reinitialize.
