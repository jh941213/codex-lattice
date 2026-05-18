---
name: release-readiness
description: "Release readiness workflow for Codex. Use before PR, merge, deploy, version bump, rollout, or production handoff to verify scope, validation evidence, rollback, migrations, operator notes, changelog, and residual risk."
---

# Release Readiness

Use this skill before PR, merge, deploy, version bump, or production handoff.

## Workflow

1. Identify release scope from `git diff`, `docs/harness/TASKS.md`, and `docs/harness/CHANGELOG.md`.
2. Confirm the release has clear acceptance criteria in `docs/harness/FEATURE_SPEC.md`.
3. Verify evidence exists in `docs/harness/VALIDATION.md`.
4. Check rollback and backout notes in `docs/harness/RELEASE_PLAN.md`.
5. Check migration risk in `docs/harness/MIGRATION_PLAN.md`.
6. Check operator impact in `docs/harness/OPERATIONS_RUNBOOK.md`.
7. Check security and data impact in `docs/harness/SECURITY_POLICY.md` and `docs/harness/DATA_GOVERNANCE.md` when present.
8. Update `docs/harness/RISKS.md` with unresolved release blockers.

## Required Output

Return:

- release scope
- validation evidence
- rollback path
- migration/data impact
- operator notes
- blockers
- release decision: `READY`, `READY_WITH_RISK`, or `BLOCKED`

## Blockers

Treat these as release blockers unless the user explicitly accepts the risk:

- no verification evidence for changed behavior
- no rollback path for stateful changes
- unreviewed auth, permissions, secrets, or PII changes
- migrations without compatibility or rollback notes
- production-facing changes without operator notes
