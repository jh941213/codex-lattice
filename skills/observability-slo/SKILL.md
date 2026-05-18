---
name: observability-slo
description: "Observability and SLO design workflow. Use when adding or reviewing logs, metrics, traces, dashboards, alerts, SLIs, SLOs, error budgets, runbooks, or production monitoring for a service or feature."
---

# Observability And SLO

Use this skill when a change needs production visibility, alerting, SLOs, or dashboard/runbook updates.

## Workflow

1. Identify the user-visible behavior that should be measured.
2. Define SLIs before alerts: availability, latency, correctness, freshness, durability, or throughput.
3. Define SLO targets and error budget policy in `docs/harness/SLO_POLICY.md`.
4. Map telemetry:
   - logs for discrete events and audit trails
   - metrics for aggregate health and alerting
   - traces for request paths and dependency latency
5. Add alert criteria only when a human action is expected.
6. Update `docs/harness/OBSERVABILITY.md` and `docs/harness/OPERATIONS_RUNBOOK.md`.
7. Add dashboard and runbook links or placeholders when live URLs are not available.

## Alert Quality Checklist

- The alert maps to a user impact or fast-moving risk.
- The alert has an owner and runbook.
- The runbook includes first diagnostics, rollback, and escalation.
- The threshold avoids paging for harmless noise.
- The signal can distinguish service failure from dependency failure where possible.

## Required Output

Return SLIs, SLOs, telemetry changes, alerts, dashboards, runbook updates, and remaining blind spots.
