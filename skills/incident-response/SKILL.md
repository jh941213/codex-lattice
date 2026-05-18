---
name: incident-response
description: "Production incident and major-error response workflow. Use for outages, degraded service, repeated hook/tool failures, security incidents, data loss, rollback decisions, on-call triage, or when MAJOR_ERRORS.md shows blocking failures."
---

# Incident Response

Use this skill when a production incident, major repeated error, rollback decision, or on-call triage is involved.

## Workflow

1. Stabilize first: stop risky changes, preserve logs, and identify the affected service or workflow.
2. Classify severity in `docs/harness/INCIDENT_RESPONSE.md`.
3. Capture timeline, impact, suspected trigger, current mitigation, and owner.
4. Prefer read-only diagnostics before mutating systems.
5. If rollback is safer than forward fix, document the rollback command and validation.
6. Update model-visible major errors only with information the next agent must read.
7. After mitigation, create or update `docs/harness/POSTMORTEM_TEMPLATE.md`.

## Severity Guide

- `SEV0`: data loss, security exposure, total outage, destructive automation.
- `SEV1`: customer-visible outage or broken critical workflow.
- `SEV2`: partial degradation, failed deployment, repeated operational failure.
- `SEV3`: non-urgent defect, flaky check, noisy alert.

## Required Output

Return:

- severity
- impact
- immediate mitigation
- diagnostics run
- rollback or forward-fix decision
- follow-up action items
- postmortem required: yes/no
