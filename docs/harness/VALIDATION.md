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
  - `CODEX_HOME=/tmp/codex-home-image codex exec --ignore-user-config --enable image_generation --sandbox workspace-write --skip-git-repo-check --cd /Users/kdb/codex-lattice ...`
  - `file assets/codex-lattice-hero.png`
  - `sips -g pixelWidth -g pixelHeight assets/codex-lattice-hero.png`
  - `git diff --check`
  - `bash scripts/check-codex-integrations.sh`
  - `gitleaks detect --source . --no-git --redact --no-banner`
- result: pass.
- skipped: no visual OCR or manual image inspection tool was run.
- evidence: `assets/codex-lattice-hero.png` is a PNG image, 1672 x 941 pixels, 8-bit RGB, 1.6 MB; integration checker reports required/recommended tools available; gitleaks found no leaks.

### 2026-05-14T07:06:56Z
- task: reconcile repository contents with the current local Codex harness install and plugin packaging.
- commands:
  - `jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json`
  - `CODEX_HOME=/tmp/codex-lattice-install-test bash install.sh --ko`
  - `rg -c '^\\[\\[skills\\.config\\]\\]' /tmp/codex-lattice-install-test/config.toml`
  - `find /tmp/codex-lattice-install-test/skills -mindepth 1 -maxdepth 1 -type d`
  - `find /tmp/codex-lattice-install-test/agents -maxdepth 1 -name '*.toml'`
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
  - `rg <legacy-harness-patterns> . --glob '!/.git/**' --glob '!skills/microsoft-agent-framework/**' --glob '!assets/codex-lattice-hero.png'`
  - `CODEX_HOME=/tmp/codex-lattice-clean-test bash install.sh --ko`
  - parse `/tmp/codex-lattice-clean-test/config.toml` with Python `tomllib`
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

### 2026-05-14T08:01:56Z
- task: remove the LangChain framework specialist from Codex custom agents.
- commands:
  - `find .codex/agents -maxdepth 1 -type f`
  - `rg <removed-agent-and-old-count-patterns> README.md README_EN.md install.sh docs .codex/agents .codex-plugin/plugin.json`
  - `CODEX_HOME=/tmp/codex-lattice-agent-test bash install.sh --ko`
  - parse `/tmp/codex-lattice-agent-test/config.toml` with Python `tomllib`
  - count temp install agent TOML files
  - apply install to local `~/.codex`
  - parse `~/.codex/config.toml` with Python `tomllib`
  - count local agent TOML files
  - `jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json`
  - `shellcheck install.sh hooks/*.sh scripts/*.sh`
  - `shfmt -d install.sh hooks/*.sh scripts/*.sh`
  - `git diff --check`
  - `bash scripts/check-codex-integrations.sh`
  - `gitleaks detect --source . --no-git --redact --no-banner`
- result: pass.
- skipped: no skill was removed; only the custom agent registration was removed.
- evidence: repo custom agents are 14 TOML files; temp install produces 14 agent TOML files; local `~/.codex` has 14 agent TOML files after reinstall; README badges/counts and installer registration no longer reference the removed custom agent; JSON/TOML, shell lint/format, whitespace, integration, and secret scans passed.

### 2026-05-15T02:44:45Z
- task: rename the distribution to `codex-lattice` and verify repo/install consistency.
- commands:
  - `rg -n --hidden <old-name-patterns> . --glob '!/.git/**'`
  - `test ! -f .codex/config.toml`
  - compare repo skill directories with installer/project registrations
  - `bash scripts/check-codex-integrations.sh`
  - `bash -n install.sh && for f in hooks/codex-*.sh scripts/check-codex-integrations.sh; do bash -n "$f"; done`
  - parse `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `.mcp.json`, and `.codex/agents/*.toml`
  - parse all `skills/*/SKILL.md` YAML frontmatter
  - `CODEX_HOME=/tmp/codex-lattice-install.* bash install.sh --ko`
  - count temp install skill config entries, skill directories, agent TOML files, hook scripts, hook command registrations
  - verify temp config has `features.hooks = true` and no `features.codex_hooks`
  - verify reinstall removes the previous managed config block
  - `shellcheck install.sh hooks/codex-*.sh scripts/check-codex-integrations.sh`
  - `shfmt -d install.sh hooks/codex-*.sh scripts/check-codex-integrations.sh`
  - `gitleaks detect --no-banner --redact --source .`
- result: pass.
- skipped: GitHub repository rename and push are tracked separately in Git history after the local validation passes.
- evidence: old-name scan returned no matches; `.codex/config.toml` was removed so installed user config is the single registration source; temp install produced 39 skill config entries, 39 skill directories, 14 agent TOML files, 8 hook scripts, and 15 hook command registrations; `features.hooks` is true and `features.codex_hooks` is absent; shell syntax, JSON/TOML/YAML parsing, shellcheck, shfmt, integration checker, and gitleaks passed.

### 2026-05-15T03:05:00Z
- task: enable Codex built-in image generation for the system `$imagegen` skill.
- commands:
  - `rg -n "image_generation|image_gen|features" ~/.codex/config.toml install.sh README.md README_EN.md .codex-plugin/plugin.json`
  - `codex exec --help`
  - `bash install.sh --ko`
  - parse `~/.codex/config.toml` and temp install config for `features.image_generation`
  - `bash -n install.sh`
  - `git diff --check`
- result: pass.
- skipped: no live image was generated during this config check.
- evidence: installer now writes `features.image_generation = true`; local `~/.codex/config.toml` has `features.image_generation = true`; `codex exec --help` confirms `--enable <FEATURE>` maps to `features.<name>=true`.
