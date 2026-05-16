# Observability

## Logs

- `.codex-lattice/logs/events.jsonl` records lifecycle events.
- `.codex-lattice/commits/` records commit candidates and commit metadata.

## Metrics

- Hook command count, skill count, agent count, integration checker status, and validation results are tracked in docs.

## Alerts

- `MAJOR_ERRORS.md` is model-visible when blocking failures recur.
- `SIMPLIFY_REQUIRED.md` and `DOCS_AGENT_REQUIRED.md` indicate pre-HITL gates.
- `REFLECTION_REQUIRED.md` indicates a newest-request and instruction-ledger check is required.

## Dashboards

- No dashboard is bundled.

## Incident Signals

- Repeated tool failures, security scans, missing MCP keys, stale docs, unresolved reflection gates, and untrusted hooks require attention.
