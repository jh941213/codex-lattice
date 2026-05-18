# Tasks

## Current

- [x] Publish a clean Codex-only harness repository.
- [x] Install the harness into the current `~/.codex` environment.
- [x] Include Codex skills, hooks, custom agents, rules, docs workflow, integration checker, and runtime memory templates.
- [x] Add Azure Infra custom agent with Azure CLI, cost review, operations monitoring, and memory rules.
- [x] Verify search/lint/security tooling coverage including `mgrep`, `rg`, `sg`, `semgrep`, `gitleaks`, `shellcheck`, `shfmt`, and `az`.
- [x] Add Tavily and Exa MCP search routing with env/`~/.mcp.json` credential fallback.
- [x] Generate a Codex README hero image and include it in Korean and English README files.
- [x] Reconcile repo skills and plugin metadata with the current local Codex harness install.
- [x] Rebuild the repository layout to remove legacy Markdown agent, duplicate language tree, and old role artifacts.
- [x] Remove the LangChain framework specialist from custom agents.
- [x] Rename the package, plugin metadata, README, runtime folder, and GitHub target to `codex-lattice`.
- [x] Remove project-level `.codex/config.toml` to avoid duplicate hook/agent registrations after install.
- [x] Add simplify gate before HITL, review, PR, or final response.
- [x] Add docs agent gate for product, feature, API, infra, security, data, test, observability, migration, release, and UX docs.
- [x] Set README/plugin version display to `0.0.1`.
- [x] Add reflection gate for multi-step prompts, compact resume, and final newest-request checks.
- [x] Add Codex-native sub-agent protocol for bounded task delegation, status handling, and staged review.
- [x] Add real-world operations/governance skills for release readiness, incident response, observability/SLO, supply-chain security, agent tool risk, Azure FinOps, data governance, and postmortems.
- [x] Expand docs gate surfaces for SLO, incident response, postmortem, supply chain, agent security, data governance, and cost model docs.
- [x] Fix docs sync and runtime logs to handle staged diffs and resolve project git roots.
- [x] Add optional scheduled operations MVP with deterministic healthcheck, log analysis, read-only Codex report mode, and enable/disable/status controls.
- [x] Polish Korean and English README structure for clearer onboarding and first-run validation.
- [x] Validate the harness with a real temporary notepad app and fix the docs-template EOF issue found during validation.
- [x] Add context/review/health packet generation and verify it in a temporary app repository.

## Status Legend

- `pending`: not started
- `in-progress`: actively being changed
- `done`: implemented and verified
- `blocked`: cannot proceed without a decision or dependency
