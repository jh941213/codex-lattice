# Production Readiness

Use this file before production or `prd` environment handoff.

## Scope

- Production-facing change:
- User/operator impact:
- Environments affected:
- Rollout owner:

## Release Gates

- Product/spec acceptance criteria are current.
- Validation evidence exists in `VALIDATION.md`.
- Security, data governance, supply-chain, cost, and SLO impacts are reviewed.
- Rollback/backout path is documented in `RELEASE_PLAN.md`.
- Operator notes and runbook updates are present.

## Production Environment Checklist

- Config and secrets are environment-scoped and not committed.
- Database migrations are backward compatible or have a documented lockstep release plan.
- Feature flags, kill switches, or gradual rollout controls are identified when blast radius is meaningful.
- Dashboards, alerts, and first diagnostic commands are linked or documented.
- Capacity, quota, dependency, and cost limits are understood before rollout.

## Go/No-Go

- Decision:
- Blockers:
- Accepted risks:
- Follow-up owner/date:
