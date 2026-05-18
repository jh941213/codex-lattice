---
name: postmortem
description: "Blameless postmortem workflow. Use after incidents, major tool failures, rollback events, security findings, data issues, monitoring failures, or repeated regression loops to capture impact, timeline, root causes, and corrective actions."
---

# Postmortem

Use this skill after incidents, major repeated tool failures, rollback events, security findings, data issues, monitoring failures, or repeated regression loops.

## Workflow

1. Keep the write-up blameless and system-focused.
2. Capture objective impact and detection source.
3. Build a timeline from logs, commits, deploys, alerts, and human actions.
4. Separate trigger, contributing factors, and root causes.
5. Write corrective actions with owners, priority, and verification.
6. Update `docs/harness/POSTMORTEM_TEMPLATE.md`.
7. Link follow-ups in `docs/harness/RISKS.md`, `docs/harness/DECISIONS.md`, and `docs/harness/OPERATIONS_RUNBOOK.md`.

## Required Sections

- Summary
- Impact
- Detection
- Timeline
- Root causes
- What went well
- What went poorly
- Corrective actions
- Prevention checks

## Required Output

Return postmortem status, missing evidence, corrective actions, and whether follow-up work should block release.
