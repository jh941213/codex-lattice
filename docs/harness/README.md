# Harness Docs

This directory is the model-visible documentation surface for Codex coding work.

Sub-agents should keep these files aligned with implementation changes:

- `PRODUCT_BRIEF.md`: problem, users, scope, non-goals, and PRD pre-questions
- `TASKS.md`: current task scope and checklist
- `FEATURE_SPEC.md`: feature behavior and acceptance criteria
- `API_SPEC.md`: endpoints, request/response, validation, and error contracts
- `INFRA_SPEC.md`: resources, configuration, operations, and monitoring
- `SECURITY_POLICY.md`: trust boundaries, auth, data handling, secrets, abuse cases
- `DATA_MODEL.md`: entities, ownership, persistence, and normalization rules
- `TEST_PLAN.md`: unit, integration, E2E, regression, and manual checks
- `OBSERVABILITY.md`: logs, metrics, alerts, dashboards, and incident signals
- `OPERATIONS_RUNBOOK.md`: SLOs, monitoring checklist, alert response, rollback, and incident review
- `MIGRATION_PLAN.md`: compatibility, data migration, rollback, and verification
- `RELEASE_PLAN.md`: version, rollout, backout, and operator notes
- `UX_SPEC.md`: primary flow, states, accessibility, and responsive behavior
- `REFLECTION.md`: drift checks for sequential work, interruptions, compact resume, and final response
- `SUBAGENT_PROTOCOL.md`: Codex-native delegation, review ordering, report statuses, and parallel ownership rules
- `DECISIONS.md`: decisions and rationale
- `CHANGELOG.md`: implementation changes
- `VALIDATION.md`: checks run and results
- `RISKS.md`: remaining risks and follow-ups

`docs_maintainer` should update these files when sub-agent delegation is available. Otherwise the parent agent must update the same files directly before HITL, review, PR, or final response.

Hidden runtime logs stay in `.codex-lattice/logs/` and should not be loaded by default.
