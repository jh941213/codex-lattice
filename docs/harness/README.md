# Harness Docs

This directory is the model-visible documentation surface for Codex coding work.

Sub-agents should keep these files aligned with implementation changes:

- `TASKS.md`: current task scope and checklist
- `DECISIONS.md`: decisions and rationale
- `CHANGELOG.md`: implementation changes
- `VALIDATION.md`: checks run and results
- `RISKS.md`: remaining risks and follow-ups

Hidden runtime logs stay in `.codex-harness/logs/` and should not be loaded by default.
