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

## Status Legend

- `pending`: not started
- `in-progress`: actively being changed
- `done`: implemented and verified
- `blocked`: cannot proceed without a decision or dependency
