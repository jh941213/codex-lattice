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

### 2026-05-14T04:13:11Z
- task: generate and publish a README hero image with the Codex image workflow.
- commands:
  - `CODEX_HOME=/tmp/codex-home-image codex exec --ignore-user-config --enable image_generation --sandbox workspace-write --skip-git-repo-check --cd /Users/kdb/my-codex-harness ...`
  - `file assets/codex-harness-hero.png`
  - `sips -g pixelWidth -g pixelHeight assets/codex-harness-hero.png`
  - `git diff --check`
  - `bash scripts/check-codex-integrations.sh`
  - `gitleaks detect --source . --no-git --redact --no-banner`
- result: pass.
- skipped: no visual OCR or manual image inspection tool was run.
- evidence: `assets/codex-harness-hero.png` is a PNG image, 1672 x 941 pixels, 8-bit RGB, 1.6 MB; integration checker reports required/recommended tools available; gitleaks found no leaks.

### 2026-05-14T07:06:56Z
- task: reconcile repository contents with the current local Codex harness install and plugin packaging.
- commands:
  - `jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json`
  - `CODEX_HOME=/tmp/my-codex-harness-install-test bash install.sh --ko`
  - `rg -c '^\\[\\[skills\\.config\\]\\]' /tmp/my-codex-harness-install-test/config.toml`
  - `find /tmp/my-codex-harness-install-test/skills -mindepth 1 -maxdepth 1 -type d`
  - `find /tmp/my-codex-harness-install-test/agents -maxdepth 1 -name '*.toml'`
  - `comm -3 <local harness skill list> <repo skill list>`
  - `bash scripts/check-codex-integrations.sh`
  - `shellcheck install.sh hooks/*.sh scripts/*.sh`
  - `shfmt -d install.sh hooks/*.sh scripts/*.sh`
  - `git diff --check`
  - `gitleaks detect --source . --no-git --redact --no-banner`
- result: pass.
- skipped: did not install the repo as a Codex plugin cache entry; validated plugin manifest/marketplace/MCP JSON shape locally instead.
- evidence: clean temp install produced 39 skill config entries, 39 skill directories, and 15 agent TOML files; local active harness skill list matches repo `skills/`; JSON, shell lint/format, integration checks, whitespace checks, and secret scan passed.

### 2026-05-14T07:14:55Z
- task: rebuild repository layout to remove legacy role-agent folders and duplicate install trees.
- commands:
  - `find . -maxdepth 2 -type d`
  - `find .codex/agents -maxdepth 1 -type f`
  - `rg <legacy-harness-patterns> . --glob '!/.git/**' --glob '!skills/microsoft-agent-framework/**' --glob '!assets/codex-harness-hero.png'`
  - `CODEX_HOME=/tmp/my-codex-harness-clean-test bash install.sh --ko`
  - parse `/tmp/my-codex-harness-clean-test/config.toml` with Python `tomllib`
  - count temp install skills, agent TOML files, and agent Markdown files
  - `bash install.sh --ko`
  - parse `~/.codex/config.toml` with Python `tomllib`
  - `bash scripts/check-codex-integrations.sh`
  - `jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json`
  - `shellcheck install.sh hooks/*.sh scripts/*.sh`
  - `shfmt -d install.sh hooks/*.sh scripts/*.sh`
  - `git diff --check`
  - `gitleaks detect --source . --no-git --redact --no-banner`
- result: pass.
- skipped: Microsoft Agent Framework reference docs were excluded from legacy-string scanning because they are upstream framework docs, not harness structure.
- evidence: repo root now contains no duplicate language install trees or Markdown role-agent folders; custom agents are 15 TOML files under `.codex/agents`; clean temp install produced 39 skills, 15 agent TOML files, 0 agent Markdown files, and no old instruction directory; local `~/.codex` now has 15 agent TOML files, 0 agent Markdown files, and no old instruction directory; legacy-string scan found no matches outside excluded upstream docs; JSON/TOML, shell lint/format, whitespace, integration, and secret scans passed.
