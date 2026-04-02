---
name: qa-tune
description: Teach the QA pipeline about your project's specific rules, patterns, and exceptions. Translates natural language instructions into rubric file edits. Use when a developer says "stop flagging X", "add a rule for Y", "we always do Z", or types /qa-tune.
---

# /qa-tune -- Teach the QA Pipeline

You translate developer instructions into rubric file edits. The developer tells you what they want in plain English, and you update the correct `.review/` file.

## Step 1: Verify .review/ Exists

Check if `.review/` directory exists with rubric files. If not:

```
.review/ directory not found. Run /qa-init first to set up the pipeline.
```

And stop.

## Step 2: Understand the Instruction

Read the developer's instruction. Classify it into one of these categories:

| Category | Target File | Example |
|----------|-------------|---------|
| **New pattern rule** | `.review/pattern-conventions.md` | "we use camelCase for DB aliases" |
| **New security rule** | `.review/security-checklist.md` | "never use eval() in worker scripts" |
| **False positive suppression** | `.review/false-positive-suppressions.md` | "stop flagging console.log in webhooks/" |
| **Review scope change** | `.review/REVIEW_RULES.md` | "don't review files in src/generated/" |
| **Multiple categories** | Multiple files | "we use Zod for all validation and flag any joi imports" |

If the instruction is ambiguous, ask the developer to clarify before editing.

## Step 3: Read the Target File

Read the rubric file you identified in Step 2. Understand:
- What sections exist
- What format the existing entries use
- Where the new rule best fits

## Step 4: Draft the Edit

Write the rule in the same format as existing entries in that file. Rules must be:
- **Specific** -- not vague ("use camelCase for DB column aliases" not "use good naming")
- **Actionable** -- the review agent can check it mechanically
- **Scoped** -- says where it applies (which files, which patterns, which directories)

### For pattern-conventions.md
Add the rule under the appropriate section heading. If no section fits, add it under the closest match. Do NOT create new sections unless the instruction clearly represents a new category.

### For security-checklist.md
Add under the appropriate severity level (BLOCK/WARN/INFO) in the Stack-Specific Items section at the bottom.

### For false-positive-suppressions.md
Add a new line under the Suppressions section:
```
- "{pattern description}" -- {reason}
```

### For REVIEW_RULES.md
Add under "What NOT To Review" if it's an exclusion, or under the appropriate section for scope changes.

## Step 5: Show the Change and Apply

Show the developer exactly what you're adding and where:

```
Adding to .review/pattern-conventions.md under "Database Query Patterns":

  - Use camelCase for column aliases in SELECT queries (e.g., `createdAt` not `created_at`)

Apply? (y/n)
```

Wait for confirmation, then make the edit.

If the developer says no or wants adjustments, revise and show again.

## Step 6: Confirm

```
Done. Rule added to .review/pattern-conventions.md.
This will take effect on the next /qa run.
```

## Handling Multiple Instructions

If the developer provides multiple rules at once (e.g., "add these 5 rules"), process each one:
1. Classify each instruction
2. Group by target file
3. Show all changes as a batch
4. Apply after confirmation

## Handling Removals

If the developer says "remove the rule about X" or "undo that":
1. Search all `.review/` files for the matching rule
2. Show what will be removed
3. Remove after confirmation

If the developer says "remove suppression for X":
1. Find the matching entry in `false-positive-suppressions.md`
2. Remove it after confirmation

## Important Rules

- ONLY edit files in `.review/`. Never touch agent files, CLAUDE.md, or source code.
- ALWAYS show the change before applying. Never silently edit rubrics.
- PRESERVE existing content. Append rules, don't reorganize or rewrite the file.
- Use the SAME format as existing entries in the target file.
- If the instruction doesn't map to a rubric change (e.g., "fix the bug on line 42"), explain that /qa-tune is for teaching review rules, not fixing code.
