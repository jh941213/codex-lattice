---
name: plan-memory-hierarchy
description: Create backend/frontend layered `.md` memory during Plan mode. Use when request includes requirements capture, memory bootstrap, or plan preparation with backend/frontend separation.
---

# Layered Project Memory

This skill creates and maintains structured markdown memory files at project start, then reuses them during planning and execution.

## Runtime Rules

1. Confirm the project root. If unclear, ask the user.
2. If `.plan-memory/` does not exist, run bootstrap script.

```bash
python3 scripts/bootstrap_plan_memory.py --root . --project-name "<project-name>"
```

3. Read core memory files:
   - `.plan-memory/README.md`
   - `.plan-memory/product/requirements.md`
   - `.plan-memory/backend/requirements.md`
   - `.plan-memory/frontend/requirements.md`
   - `.plan-memory/shared/constraints.md`
4. Store new information in the most relevant layer file, not in a single aggregate file.
5. Before final plan output, update `.plan-memory/README.md` summary index.

## Use Cases

- New project intake with requirements capture
- Splitting work by backend/frontend scope
- Long-running refactor/integration work requiring persistent context

## 스크립트 동작

### Default directory tree

```text
.plan-memory/
  README.md
  product/requirements.md
  product/acceptance-criteria.md
  backend/requirements.md
  backend/api-contracts.md
  backend/data-model.md
  frontend/requirements.md
  frontend/ux-flow.md
  frontend/state-management.md
  shared/constraints.md
  shared/glossary.md
  execution/current-plan.md
  execution/open-questions.md
```

### Key Rules

- Existing files are preserved by default; do not overwrite unless `--force` is passed.
- For edits, ask for user confirmation before deleting/replacing existing docs.
- For new projects, fill `execution/current-plan.md` and `product/acceptance-criteria.md` first.

## Maintenance Rules

- Keep backend and frontend assumptions separate.
- Put cross-cutting rules (security/performance/compliance) in `shared/constraints.md`.
- Keep the summary index in `README.md` in sync with added layers/files.
- End each planning pass by writing plan/risk/acceptance updates into `execution/current-plan.md`.

## 스크립트 위치

- `/Users/kdb/.codex/skills/plan-memory-hierarchy/scripts/bootstrap_plan_memory.py`

## Failure Handling

- Stop and ask for confirmation if root is unclear.
- On filesystem errors, report exact failed path and error message.
