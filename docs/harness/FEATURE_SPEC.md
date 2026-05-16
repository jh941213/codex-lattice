# Feature Spec

## Current Behavior

- Codex Lattice installs skills, hooks, custom agents, rules, MCP search config, and runtime memory templates.
- Coding work is tracked through docs/harness and project-local `.codex-lattice/` runtime files.

## Intended Behavior

- Every code change should leave feature behavior and acceptance criteria synchronized with implementation.
- When code changes are detected, the docs gate requires `docs_maintainer` or the parent agent to update this file before HITL, review, or final response.
- Complex sequential prompts and post-compact resumes should produce a reflection gate that forces newest-request alignment before continuing.

## Acceptance Criteria

- Feature-level changes describe user-visible behavior, non-goals, and acceptance criteria.
- Refactors that do not alter behavior explicitly say behavior is unchanged.
- Validation evidence is linked from `VALIDATION.md`.
- Reflection prompts create `.codex-lattice/model-visible/REFLECTION_REQUIRED.md` without mutating source code.
