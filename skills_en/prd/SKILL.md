---
name: prd
description: >
  Codex PRD/SPEC authoring skill. Turns an idea into CPS, PRD, market, user, feature, risk, and SPEC documents.
  Triggers: "$prd", "write PRD", "product planning", "organize idea", "requirements document", "CPS"
  Anti-triggers: already-scoped small code changes, simple bug fixes
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# PRD

Use `$prd` for PRD and SPEC planning output.

## Outputs

```text
prd/
├── CPS.md
├── PRD.md
├── MARKET.md
├── USERS.md
├── FEATURES.md
├── RISKS.md
├── SPEC.md
└── APPENDIX.md
```

## Process

1. If `prd/` already exists, ask whether to continue from it.
2. Classify complexity:
   - Low: simple feature/tool/CLI, minimal research.
   - Mid: new module/service/library, focused research.
   - High: new product/SaaS/platform, fuller research and interviews.
3. Lock CPS first:
   - Context: situation and environment.
   - Problem: concrete problem and measurable impact.
   - Solution: target success state.
4. Ask only 1-3 questions at a time.
5. Write features with user stories, acceptance criteria, priority, and non-goals.
6. Write SPEC with stack, architecture, API, data model, security, and deployment constraints.
7. Verify that `FEATURES.md` and `SPEC.md` support each other.

## Research

If market or technical facts are time-sensitive, verify them with official docs, GitHub, or web search and record sources in `APPENDIX.md`.

## Output

```md
## PRD Result
- created/updated:
- unresolved questions:
- assumptions:
- next skill:
```
