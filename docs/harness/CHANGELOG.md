# Harness Changelog

## Unreleased

- Published clean Codex-only harness layout.
- Added Codex plugin metadata, 36 skills, 15 custom agents, 15 lifecycle hooks, rules, installer, and integration checker.
- Added always-on Git strategy logging, hidden event logging, commit metadata logging, major-error memory, Azure Infra memory, and docs sync queue behavior.
- Added Azure Infra agent for Azure CLI based sizing, resource review, operations monitoring, cost/security/reliability analysis, and memory updates.
- Added integration coverage for `mgrep`, `ripgrep`, `ast-grep`, `semgrep`, `gitleaks`, `scc`, `shellcheck`, `shfmt`, `osv-scanner`, and `azure-cli`.
- Documented `mgrep install-codex` sync behavior so users can decide whether semantic search is appropriate for sensitive repositories.
- Added Tavily and Exa MCP config for web search/research. The config reads API keys from environment variables first, then falls back to existing `~/.mcp.json` entries.
