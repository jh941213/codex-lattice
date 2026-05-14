# Validation

Track checks run for each coding task.

## Template

```md
### YYYY-MM-DDTHH:MM:SSZ
- task:
- commands:
- result:
- skipped:
- evidence:
```

### 2026-05-14T02:37:37Z
- task: clean Codex-only harness export and local environment install.
- commands:
  - `bash scripts/check-codex-integrations.sh`
  - `bash install.sh --ko`
  - parse `~/.codex/config.toml` for `features.hooks`, `features.multi_agent`, `features.plugins`, `features.goals`
  - verify installed agent count and `azure_infra` registration
  - verify Azure CLI with `az version` and local login status with `az account show --output json`
  - install mgrep Codex MCP integration with `mgrep install-codex`
  - verify mgrep MCP entry with `codex mcp list`
  - add Tavily and Exa Codex MCP entries using existing `~/.mcp.json` credentials without copying secrets into the repo
  - parse Codex MCP config and confirm `tavily`, `exa`, and `mgrep` entries exist
- result: pass.
- skipped: no Azure resources were enumerated or changed; no cost, Advisor, metrics, or diagnostic settings were queried yet.
- evidence: integration checker reports `mgrep`, `rg`, `sg`, `semgrep`, `gitleaks`, `scc`, `shellcheck`, `shfmt`, `az`, Tavily key availability, Exa key availability, and related tools available; local config has 15 agents including `azure_infra`; Azure memory file exists; Codex MCP config has `mgrep`, `tavily`, and `exa`.
