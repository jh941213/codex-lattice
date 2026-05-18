# Operations Runbook

## SLOs

- Codex Lattice should install without corrupting existing user configuration.
- Hook failures should not block normal Codex execution unless a separate guard hook intentionally blocks a dangerous action.

## Monitoring Checklist

- Check `/hooks` after install and confirm installed hooks are trusted and active.
- Run `~/.codex/scripts/check-codex-integrations.sh` after setup changes.
- Run `./scripts/validate-codex-lattice-runtime.sh` before production/`prd` handoff or after hook/agent changes.
- Run `./scripts/codex-lattice-scheduler.sh run` for a deterministic healthcheck and log-analysis report.
- Use `./scripts/codex-lattice-scheduler.sh status` to check optional scheduled operations.
- Check `.codex-lattice/model-visible/MAJOR_ERRORS.md` after repeated tool failures.
- Check `.codex-lattice/model-visible/REFLECTION_REQUIRED.md` before HITL, PR, merge, or final response.
- Check `.codex-lattice/model-visible/SIMPLIFY_REQUIRED.md` before HITL, review, or PR.
- Check `.codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md` before HITL, review, or PR.

## Alert Response

- Missing required tools: install via `brew bundle --file Brewfile.codex` and rerun the checker.
- Hook review pending: open `/hooks`, inspect commands, and trust expected hooks.
- MCP search failure: verify `TAVILY_API_KEY`, `EXA_API_KEY`, or existing `~/.mcp.json`.
- Azure discovery failure: run `az login` and confirm `az account show` before asking `azure_infra` for live cloud state.

## Rollback

- Revert the harness commit or reinstall a previous release.
- Restore `~/.codex/config.toml` from backup if installer output is wrong.
- Disable scheduled operations with `./scripts/codex-lattice-scheduler.sh disable` before reverting scheduler changes.
- Remove stale `.codex-lattice/model-visible/*_REQUIRED.md` files only after the underlying issue is resolved.
- Production/`prd` rollback must check config, scheduler, hooks, MCP search credentials, and any cloud resource assumptions recorded in `INFRA_SPEC.md` or `AZURE_INFRA_MEMORY.md`.

## Incident Review

- Record cause, affected hooks/skills/agents, verification gaps, and follow-up rules in `RISKS.md` and `DECISIONS.md`.
