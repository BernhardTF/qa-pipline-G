---
description: "Project-specific coding conventions. Template -- run qa-init to populate from CLAUDE.md, or edit manually."
---

# Pattern Conventions

This file defines project-specific coding patterns. The qa-patterns agent checks the diff against these rules.

**This is a template.** Run the qa-init skill to auto-populate from your project's CLAUDE.md, or edit manually.

## File Naming
<!-- Example: kebab-case for all files, PascalCase for components internally -->

## Import Patterns
<!-- Example: Use @/ alias for all imports, type imports with `import type` -->

## Export Patterns
<!-- Example: Named exports for components, default exports only for page.tsx/layout.tsx -->

## Component Patterns
<!-- Example: UI primitives use CVA for variants, domain components contain business logic -->

## API Route Patterns
<!-- Example: Always validate input with Zod, check auth, return ApiResponse<T> -->

## Database Query Patterns
<!-- Example: Composite primary keys on partitioned tables, use ORM patterns -->

## Error Handling Patterns
<!-- Example: Try/catch on async operations, consistent error response format -->

## State Management Patterns
<!-- Example: React Query for server state, local state for UI-only state -->

## Testing Patterns
<!-- Example: Integration tests hit real DB, unit tests for pure functions -->
