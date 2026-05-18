---
name: data-governance
description: "Data governance workflow. Use when handling PII, privacy, retention, data classification, access control, audit logs, schema ownership, data migrations, analytics events, or compliance-sensitive changes."
---

# Data Governance

Use this skill when a change touches PII, privacy, retention, data classification, access control, audit logs, analytics events, schema ownership, or compliance-sensitive data.

## Workflow

1. Identify data classes: public, internal, confidential, secret, PII, regulated.
2. Identify where data enters, persists, leaves, and gets logged.
3. Confirm validation and minimization at external boundaries.
4. Confirm retention and deletion expectations.
5. Check access control and audit trail requirements.
6. Check whether migrations preserve ownership and rollback expectations.
7. Update `docs/harness/DATA_GOVERNANCE.md`, `docs/harness/DATA_MODEL.md`, and `docs/harness/SECURITY_POLICY.md`.

## Red Flags

- PII in logs, model-visible files, telemetry, screenshots, or test fixtures.
- Broad admin access without audit.
- Analytics events with raw user content.
- Data retention without deletion path.
- Schema changes without migration verification.

## Required Output

Return data classes, flows, storage, retention, access controls, audit evidence, and unresolved compliance risk.
