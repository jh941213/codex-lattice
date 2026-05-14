# Risks

## Open

- `mgrep install-codex` can sync working-directory file content to Mixedbread for semantic search. Use it only when repository data policy allows that.
- `/goal` is an experimental Codex feature and requires `features.goals = true`.
- Azure Infra agent defaults to read-only. Mutating cloud operations still require explicit approval and scoped rollback planning.
- Tavily and Exa MCP require API keys through environment variables or `~/.mcp.json`; missing keys should degrade to other available search tools.
- `osv-scanner` only applies when a project has package manifests or lockfiles.

## Resolved

- Clean repository layout excludes legacy command folders, old platform plugin metadata, generated image outputs, and conversion workspace artifacts.
- Integration checker now covers `mgrep`, `ripgrep`, `ast-grep`, `semgrep`, and Azure CLI in addition to the original lint/security tooling.
- Tavily and Exa search MCP are configured without committing API keys.
