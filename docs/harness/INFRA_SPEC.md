# Infra Spec

## Resources

- Codex Lattice itself does not provision cloud resources.
- The `azure_infra` custom agent records durable Azure findings in `.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md`.

## Configuration

- Installer writes Codex configuration under `~/.codex/config.toml`.
- MCP search credentials are read from environment variables first, then from existing `~/.mcp.json` entries.
- Production/`prd` environment assumptions belong in `ENVIRONMENT_STRATEGY.md` and must identify config, secret owners, promotion source, approvals, and observability coverage.

## Operations And Monitoring

- Hooks record task events, git strategy, commit candidates, major errors, docs sync requirements, and simplify gate requirements.
- Infra changes must include cost, reliability, security, rollback, and monitoring notes before HITL.
- Azure resource reviews should update `COST_MODEL.md`, `SLO_POLICY.md`, `OBSERVABILITY.md`, and `OPERATIONS_RUNBOOK.md` when live cloud assumptions change.
- Production-facing infra work must update `PRODUCTION_READINESS.md` before PR or merge.
