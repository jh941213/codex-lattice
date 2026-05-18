# Environment Strategy

Use this file to keep local, test, staging, and production/`prd` environments aligned.

## Environment Matrix

| Environment | Purpose | Data Class | Deploy Source | Approval | Observability |
|-------------|---------|------------|---------------|----------|---------------|
| local | developer feedback | synthetic | working tree | developer | local logs/tests |
| test/ci | automated verification | synthetic | PR branch | CI | test reports |
| staging | release rehearsal | masked/synthetic | release candidate | owner approval | production-like dashboards |
| production/prd | user traffic | real data | approved release | release gate | SLO dashboards and alerts |

## Configuration Rules

- Keep environment-specific values outside source control.
- Document required variables, defaults, and secret owners.
- Prefer least-privilege credentials per environment.
- Do not let local/staging shortcuts become production defaults.

## Data Rules

- Production data must not be copied to lower environments without masking and approval.
- Migration rehearsal should happen before production when schema or data shape changes.
- Query plans and indexes should be validated against production-like cardinality without exposing sensitive data.

## Promotion Rules

- Promote artifacts forward; do not rebuild different artifacts per environment unless documented.
- Require validation evidence before staging and production promotion.
- Production rollback must identify config, database, cache, queue, and infra state implications.
