# Observability

## Logs

- `.codex-lattice/logs/events.jsonl` records lifecycle events.
- `.codex-lattice/commits/` records commit candidates and commit metadata.
- `.codex-lattice/reports/` records scheduled healthcheck, log-analysis, and operations reports.

## Metrics

- Hook command count, skill count, agent count, integration checker status, and validation results are tracked in docs.
- Release readiness should include SLI/SLO impact in `SLO_POLICY.md` when a feature changes production behavior.
- Azure or cloud-facing work should include cost and resource signals in `COST_MODEL.md`.

## Alerts

- `MAJOR_ERRORS.md` is model-visible when blocking failures recur.
- `SIMPLIFY_REQUIRED.md` and `DOCS_AGENT_REQUIRED.md` indicate pre-HITL gates.
- `REFLECTION_REQUIRED.md` indicates a newest-request and instruction-ledger check is required.
- Scheduled operations are optional and off by default; use `scripts/codex-lattice-scheduler.sh status` to confirm whether launchd is active.

## Dashboards

- No dashboard is bundled.

## Incident Signals

- Repeated tool failures, security scans, missing MCP keys, stale docs, unresolved reflection gates, and untrusted hooks require attention.
- Production-facing incidents should move through `INCIDENT_RESPONSE.md` and, when significant, `POSTMORTEM_TEMPLATE.md`.
