# QA Pipeline

Multi-agent code review pipeline for VS Code Copilot and Claude Code. Reviews your changes for security, correctness, pattern compliance, and API usage before you commit.

## What It Does

Spawns 4 specialist agents in parallel:
- **qa-security** -- OWASP Top 10, secrets, injection, missing auth
- **qa-correctness** -- logic bugs, edge cases, null safety, async errors
- **qa-patterns** -- project convention compliance (from CLAUDE.md)
- **qa-docs** -- library API verification via Context7 live docs

Findings are scored 0-100. Only 75+ confidence findings appear in the report. Output: **PASS / WARN / BLOCK** verdict with max 7 actionable findings.

## Install

```bash
git clone https://github.com/BernhardTF/qa-pipline-G.git /tmp/qa-pipeline && /tmp/qa-pipeline/install.sh .   && rm -rf /tmp/qa-pipeline
```

The installer:
- Creates `.github/agents/`, `.github/instructions/`, `.github/skills/` subdirectories
- Adds `.vscode/mcp.json` for Context7
- **Never overwrites** existing files

## Usage

### VS Code Copilot
1. Open Copilot Chat
2. Select **qa-orchestrator** from the agent dropdown
3. Type: "Review my changes"

### Claude Code
```
/qa-init    # first time only -- customizes rubrics for your stack
/qa         # review current changes
/qa-fixit   # auto-fix findings from the last review
/qa-tune    # teach the pipeline your project's rules
```

## Setup

After install, run **qa-init** to customize the pipeline for your project:

1. Detects your tech stack (framework, ORM, validation, etc.)
2. Reads your `CLAUDE.md` for project conventions
3. Queries Context7 for framework-specific security guidance
4. Creates `.review/` directory with customized rubric files

Without qa-init, the pipeline still works but uses generic rubrics.

## Teaching the Pipeline

After qa-init, use `/qa-tune` to teach the pipeline your team's specific rules in plain English. It translates your instructions into rubric file edits.

### Adding Rules

```
/qa-tune "all API routes must return { success, data, error } shape"
→ adds to .review/pattern-conventions.md under API Route Patterns

/qa-tune "never use eval() or new Function() in worker scripts"
→ adds to .review/security-checklist.md under Stack-Specific Items

/qa-tune "we use date-fns not dayjs, flag any dayjs imports"
→ adds to .review/pattern-conventions.md under Import Patterns
```

### Suppressing False Positives

```
/qa-tune "stop flagging console.log in src/lib/n8n/"
→ adds to .review/false-positive-suppressions.md

/qa-tune "the /api/health endpoint is intentionally public, no auth needed"
→ adds to .review/false-positive-suppressions.md
```

### Adjusting Scope

```
/qa-tune "don't review files in src/generated/"
→ adds exclusion to .review/REVIEW_RULES.md

/qa-tune "remove the rule about camelCase DB aliases"
→ finds and removes the matching rule after confirmation
```

Every edit is shown for confirmation before applying. Rules take effect on the next `/qa` run. Commit `.review/` to share rules with your team.

## Fixing Issues

After `/qa` finds issues, run `/qa-fixit` to auto-fix them in batch.

```
/qa          # review finds 5 issues (2 BLOCK, 3 WARN)
/qa-fixit    # reads the report, shows fix plan, applies all fixes
```

What it does:
1. Reads the latest report from `.review/reports/`
2. Shows all BLOCK and WARN findings as a fix plan
3. After confirmation, applies each fix and tracks progress
4. Updates the report in place -- changes `[BLOCK]` to `[FIXED]`, adds new line references
5. Skips findings that are too complex for auto-fix (flags them for manual attention)

Example updated report entry:
```markdown
### 1. [FIXED] ~~Missing auth check~~
**Agent:** qa-security | **Confidence:** 85/100
**Original:** `src/app/api/leads/route.ts:14`
**Fixed at:** `src/app/api/leads/route.ts:16`
**Status:** Fixed by /qa-fixit
```

The typical workflow:
```
/qa-init              # once per project
/qa                   # review before commit
/qa-fixit             # fix what was found
git add . && git commit
```

## What Gets Installed

```
.github/
  agents/
    qa-orchestrator.agent.md   # Pipeline orchestrator
    qa-security.agent.md       # Security specialist
    qa-correctness.agent.md    # Correctness specialist
    qa-patterns.agent.md       # Pattern compliance
    qa-docs.agent.md           # API docs verification
  instructions/
    review-rules.instructions.md
    security-checklist.instructions.md
    pattern-conventions.instructions.md
    scoring-rubric.instructions.md
    false-positives.instructions.md
  skills/
    qa/SKILL.md                # /qa command
    qa-init/SKILL.md           # /qa-init command
    qa-tune/SKILL.md           # /qa-tune command
    qa-fixit/SKILL.md          # /qa-fixit command
.vscode/
  mcp.json                     # Context7 MCP server config
```

After running qa-init, your project also gets:

```
.review/
  REVIEW_RULES.md              # Master review contract
  security-checklist.md        # Stack-specific security checklist
  pattern-conventions.md       # Your project's conventions
  false-positive-suppressions.md  # Team-maintained ignore list
  scoring-rubric.md            # Confidence scoring guide
  reports/                     # Review audit trail (auto-created)
```

Commit `.review/` to share review rules with your team.

## Requirements

- VS Code with GitHub Copilot extension, or Claude Code CLI
- Node.js (for Context7 MCP server via npx)
