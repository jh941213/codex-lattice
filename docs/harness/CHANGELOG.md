# Harness Changelog

## Unreleased

- Published clean Codex-only harness layout.
- Added Codex plugin metadata, 39 skills, 14 custom agents, 18 lifecycle hooks, rules, installer, and integration checker.
- Added always-on Git strategy logging, hidden event logging, commit metadata logging, major-error memory, Azure Infra memory, and docs sync queue behavior.
- Added Azure Infra agent for Azure CLI based sizing, resource review, operations monitoring, cost/security/reliability analysis, and memory updates.
- Added integration coverage for `mgrep`, `ripgrep`, `ast-grep`, `semgrep`, `gitleaks`, `scc`, `shellcheck`, `shfmt`, `osv-scanner`, and `azure-cli`.
- Documented `mgrep install-codex` sync behavior so users can decide whether semantic search is appropriate for sensitive repositories.
- Added Tavily and Exa MCP config for web search/research. The config reads API keys from environment variables first, then falls back to existing `~/.mcp.json` entries.
- Added a Codex-generated README hero image and wired it into the Korean and English README files.
- Synced repo skills with the current local harness skill list: `codex-image`, `microsoft-agent-framework`, and `plan-memory-hierarchy`.
- Added plugin MCP metadata for `mgrep`, Tavily, and Exa, and constrained installer skill registration to repo-provided skills.
- Rebuilt the repo layout around Codex-native installed surfaces only: `skills/`, `.codex/agents/*.toml`, `hooks/`, `rules/`, plugin metadata, MCP config, installer, and docs.
- Removed duplicate language-specific install trees, Markdown role-agent copies, and old role source folders.
- Renamed custom agent config files to neutral Codex-native names: `qa.toml` and `evaluator.toml`.
- Removed the LangChain framework specialist from custom agents; framework guidance remains available through skills and direct documentation lookup.
- Renamed the distribution to `codex-lattice`, including plugin metadata, README badges, clone URLs, hero asset path, stable Codex docs, and project-local runtime folder `.codex-lattice/`.
- Added legacy managed-block cleanup so reinstalling `codex-lattice` removes the previous installer block before writing the new Codex config block.
- Added `uv`, `ruff`, and `pnpm` to `Brewfile.codex` to match the integration checker recommendations.
- Removed project-level `.codex/config.toml`; `install.sh` is the single source that writes Codex config entries, which prevents duplicate hook review prompts inside the repo.
- Enabled `features.image_generation = true` so the system `$imagegen` skill can access Codex's built-in `image_gen` tool without requiring `OPENAI_API_KEY`.
- Set the public README/plugin version to `0.0.1`.
- Added `codex-simplify-gate.sh` and registered it on PostToolUse, PermissionRequest, and Stop so code changes trigger model-visible simplify requirements before HITL, review, PR, or final response.
- Expanded docs sync into a docs agent gate that creates `DOCS_AGENT_REQUIRED.md` and classifies required docs by changed file type.
- Added product, feature, API, infra, security, data model, test plan, observability, migration, release, and UX documentation surfaces under `docs/harness/`.
- Added an operations runbook documentation surface for SLOs, monitoring checks, alert response, rollback, and incident review.
- Strengthened `rules/coding-style.md` with separation, normalization, simplification, and refactoring rules.
