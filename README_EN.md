<div align="center">

**🌐 English | [한국어](README.md)**

<img src="assets/lilysTextLogo.svg" alt="Codex Lattice" width="96" />

# Codex Lattice

**An installable agent-first harness for OpenAI Codex**

[![Version](https://img.shields.io/badge/version-0.0.1-7C3AED.svg?style=for-the-badge)](https://github.com/jh941213/codex-lattice)
[![License](https://img.shields.io/badge/license-MIT-E87C3E.svg?style=for-the-badge)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-39-blue.svg?style=for-the-badge)](#39-skills)
[![Agents](https://img.shields.io/badge/agents-14-green.svg?style=for-the-badge)](#14-custom-agents)
[![Hooks](https://img.shields.io/badge/hooks-21-111827.svg?style=for-the-badge)](#always-on-hooks)

`Skills` · `Custom Agents` · `Hooks` · `Git Strategy` · `Docs Sync` · `Major Error Log`

<img src="assets/codex-lattice-hero.png" alt="Codex Lattice hero illustration" width="880" />

</div>

---

## What This Is

This repository installs a Codex harness with **39 skills**, **14 custom agents**, **21 lifecycle hooks**, task logs, commit logs, model-visible major error logs, Azure Infra memory, and always-on docs synchronization rules.

The target loop is:

```text
plan -> write Git strategy -> implement -> log events -> verify -> update docs/harness -> record commit candidates
```

## Quick Install

The commands below assume macOS and Homebrew.

```bash
git clone https://github.com/jh941213/codex-lattice.git
cd codex-lattice

# Code search, structural diff, secret scanning, shell validation
brew bundle --file Brewfile.codex

# mgrep semantic search integration
npm install -g @mixedbread/mgrep

# Optional: keep Tavily/Exa MCP keys in env vars or ~/.mcp.json
export TAVILY_API_KEY="<your tavily key>"
export EXA_API_KEY="<your exa key>"

# English harness install
bash install.sh --en
```

Restart Codex after installation. On the first run, open `/hooks`, review the new hooks, and trust them.

```text
/hooks
```

`21 hooks need review before they can run` is expected after a fresh install. Once trusted, the `/hooks` screen should show matching `Installed` and `Active` counts.

## Prerequisites

| Class | Tool | Check |
|-------|------|-------|
| Required | Git | `git --version` |
| Required | Python 3.11+ recommended | `python3 --version` |
| Required | OpenAI Codex CLI | `codex --version` |
| Recommended | Homebrew | `brew --version` |
| Recommended | GitHub CLI | `gh --version` |

Integration tools are installed through `Brewfile.codex`.

| Tool | Purpose |
|------|---------|
| `rg`, `fd` | Fast file and text search |
| `jq`, `yq` | JSON, YAML, and config inspection |
| `mgrep` | Semantic local search and Codex MCP integration |
| Tavily MCP | Fresh web search and page extraction |
| Exa MCP | Higher-quality web/research search with source gathering |
| `ast-grep` (`sg`) | AST-aware pattern detection |
| `semgrep` (`sgrep` compatibility checked) | Rule-based security and static analysis |
| `difftastic` (`difft`) | Structural diffs with less formatting noise |
| `gitleaks` | Secret scanning |
| `scc` | Code statistics and complexity |
| `shellcheck`, `shfmt` | Hook and installer shell quality |
| `osv-scanner` | Dependency vulnerability checks |
| `uv`, `ruff`, `pnpm` | Python/Node validation and fast local tool execution |
| `git-delta` | More readable diffs |
| `az` (`azure-cli`) | Azure resource review, cost estimation, operations monitoring |

If a tool is missing, skills and agents skip that check where possible. For team use, run `brew bundle --file Brewfile.codex`.

`mgrep install-codex` can sync working-directory file content to Mixedbread for semantic search. Enable it only after checking the policy for sensitive repositories.

Tavily/Exa MCP keys are not stored in this repository. The installer config first reads `TAVILY_API_KEY` and `EXA_API_KEY` from the environment, then falls back to existing `tavily`/`exa` entries in `~/.mcp.json`.

## Codex Plugin Structure

This repository root is the Codex plugin root.

| File | Role |
|------|------|
| `.codex-plugin/plugin.json` | Codex plugin manifest declaring `skills`, `hooks`, and `mcpServers` paths |
| `.mcp.json` | MCP config for `mgrep`, Tavily, and Exa when installed as a plugin |
| `.agents/plugins/marketplace.json` | Local marketplace. `source.path` points at this repo root, `./` |

So the repo has Codex plugin metadata for distribution, while `install.sh` still copies and registers the same harness into the current `~/.codex` layout.

## Installed Layout

```text
~/.codex/
├── config.toml                         # managed features, skills, hooks, agents
├── skills/                             # 39 Codex skills
├── agents/                             # 14 custom agent TOML files
├── hooks/                              # 21 lifecycle hook command registrations
├── rules/                              # Git/workflow rules
├── scripts/check-codex-integrations.sh # install validation helper
```

Project-local runtime logs are written under `.codex-lattice/`.

```text
.codex-lattice/
├── git-strategy.md
├── logs/events.jsonl
├── commits/*.json
├── commits/*.md
├── docs-sync-queue.jsonl
├── simplify-state.json
└── model-visible/
    ├── MAJOR_ERRORS.md
    ├── SIMPLIFY_REQUIRED.md
    ├── DOCS_AGENT_REQUIRED.md
    └── REFLECTION_REQUIRED.md
```

## Always-On Hooks

These run through Codex lifecycle hooks. They are not user-invoked skills.

| Hook | Role |
|------|------|
| `codex-git-strategy-log.sh` | Records branch, commit split, validation, and rollback strategy for each task |
| `codex-event-log.sh` | Writes session, prompt, tool, compact, and stop events as JSONL |
| `codex-commit-log.sh` | Writes JSON and Markdown commit metadata after `git commit` |
| `codex-major-error-log.sh` | Stores blocking or repeated failures in model-visible `MAJOR_ERRORS.md` |
| `codex-docs-sync-log.sh` | Queues changed files and marks the docs agent gate |
| `codex-simplify-gate.sh` | Marks the simplify gate after repeated code edits, large diffs, HITL, or Stop |
| `codex-reflection-reminder.sh` | Marks the reflection gate for complex sequential prompts or post-compact resume |
| `codex-visible-error-reminder.sh` | Reminds the agent to inspect major errors after session start or compact |
| `codex-git-guard.sh` | Blocks force pushes, protected-branch direct pushes, and `.env` commits |
| `codex-prettier.sh` | Reserved hook slot for formatter integration |

## Pre-HITL Gates

When code changes exist, hooks do not edit code automatically. They create model-visible gate files.

| Gate | Generated file | Required handling |
|------|----------------|-------------------|
| reflection gate | `.codex-lattice/model-visible/REFLECTION_REQUIRED.md` | Re-check the newest instruction, sequence, dependencies, and completion criteria |
| simplify gate | `.codex-lattice/model-visible/SIMPLIFY_REQUIRED.md` | Simplify/normalize and re-verify before HITL, review, or PR |
| docs agent gate | `.codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md` | `docs_maintainer` or the parent agent updates docs against the real diff |

The docs gate requests these files depending on the changed files.

| Doc | Purpose |
|-----|---------|
| `PRODUCT_BRIEF.md` | Problem, users, scope, non-goals, and open PRD questions |
| `FEATURE_SPEC.md` | Feature behavior and acceptance criteria |
| `API_SPEC.md` | Endpoints, request/response, validation, and error contracts |
| `INFRA_SPEC.md` | Resources, configuration, operations, and monitoring |
| `SECURITY_POLICY.md` | Trust boundaries, auth, data, secrets, abuse/failure modes |
| `DATA_MODEL.md` | Entities, ownership, persistence, and normalization |
| `TEST_PLAN.md` | Unit, integration, E2E, regression, and manual checks |
| `OBSERVABILITY.md` | Logs, metrics, alerts, dashboards, and incident signals |
| `OPERATIONS_RUNBOOK.md` | SLOs, monitoring checklist, alert response, rollback, and incident review |
| `MIGRATION_PLAN.md` | Compatibility, data migration, rollback, and verification |
| `RELEASE_PLAN.md` | Version, rollout, backout, and operator notes |
| `UX_SPEC.md` | Flows, states, accessibility, and responsive behavior |

## Codex Built-Ins First

The harness does not recreate what Codex already provides.

| Prefer | Use it for | Harness addition |
|--------|------------|------------------|
| `/goal` | Long-running objectives and done conditions | Durable progress in `docs/harness/TASKS.md` and `VALIDATION.md` |
| `/plan` | Scope and risk breakdown before implementation | Promote to `$plan` or execution docs only when persistence is needed |
| `/review` | Fast review of the current diff | Add `$review`, `code_reviewer`, or `security_reviewer` for deeper checks |
| `/diff` | Inspecting edits | Combine with `difft` and commit candidate logs |
| `/compact` | Summarizing long sessions | Check major errors and work docs before and after compaction |
| `/agent` | Inspecting sub-agent state | Role guidance from `.codex/agents/*.toml` |
| `/debug-config`, `/plugins`, `/mcp` | Config, plugin, and MCP diagnostics | Reproducible installer and validation scripts |
| `$imagegen` | Codex built-in image generation | Installer enables `features.image_generation = true` so the built-in `image_gen` tool can be used |

## Search Routing

| Search type | Prefer |
|-------------|--------|
| Local semantic file search | `mgrep` |
| Exact code/text search | `rg`, then `sg` when AST matching helps |
| Fresh web search/page extraction | Tavily MCP |
| Evidence-oriented web/research search | Exa MCP |
| Official OpenAI docs | `openaiDeveloperDocs` MCP |

No `&goal` alias is installed. Codex built-ins use `/goal`; harness skills use `$verify`.

## 39 Skills

| Skill | Use case |
|-------|----------|
| `$prd` | Turn an idea into CPS, PRD, MARKET, USERS, FEATURES, RISKS, SPEC, APPENDIX |
| `$plan`, `$spec`, `$spec-verify` | Planning, specification, and implementation verification |
| `$autodev`, `$autodev-parallel` | `/goal`-based single and parallel autonomous development loops |
| `$verify`, `$review`, `$simplify`, `$techdebt` | Validation, review, simplification, and tech-debt cleanup |
| `$commit-push-pr`, `$handoff`, `$compact-guide` | Commit/push/PR, handoff, and context management |
| `$build-fix`, `$tdd`, `$e2e-verify`, `$e2e-agent-browser` | Build recovery, TDD, and E2E verification |
| `$frontend`, `$ui-ux-pro-max`, `$react-patterns`, `$shadcn-ui`, `$tailwind-design-system` | UI, React, Tailwind, and design systems |
| `$harness-diagnostics`, `$harness-audit`, `$eval` | Harness diagnostics, audit, and quality evaluation |
| Technical skills | FastAPI, API design, async Python, pytest, TypeScript, Vercel React, Stitch, Nano Banana, Codex image, Microsoft Agent Framework, layered plan memory |

## 14 Custom Agents

| Agent | Role |
|-------|------|
| `planner` | Scope, order, risks, validation criteria |
| `architect` | Module boundaries, dependency direction, migration risks |
| `frontend_developer` | UI, React, accessibility, responsive implementation |
| `junior_mentor` | Beginner-friendly implementation notes |
| `prd_planner` | CPS, PRD, and SPEC synthesis |
| `code_reviewer` | Bugs, regressions, missing tests, structural diff review |
| `security_reviewer` | Secrets, authorization, input validation, dependency security |
| `azure_infra` | Azure CLI based sizing, cost/security/ops review, monitoring, and Azure memory updates |
| `qa` | User scenarios and verification checklists |
| `evaluator` | Independent quality scoring and improvement loops |
| `docs_writer` | Product and technical docs |
| `docs_maintainer` | Keeps `docs/harness/` aligned with the real diff |
| `tdd_guide` | Test-first design |
| `stitch_developer` | Stitch-to-React conversion |

Custom agents use only `.codex/agents/*.toml`. Markdown role files are not installed.

## First-Run Checks

After installing:

```bash
~/.codex/scripts/check-codex-integrations.sh
```

To validate this repository itself:

```bash
bash scripts/check-codex-integrations.sh
bash -n install.sh
for f in hooks/codex-*.sh scripts/check-codex-integrations.sh; do bash -n "$f"; done
```

Inside Codex, inspect:

```text
/debug-config
/hooks
/status
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `21 hooks need review before they can run` | Open `/hooks`, review the hooks, and trust them once. |
| `[features].codex_hooks is deprecated` | Old config. Run `bash install.sh --en` again to write `features.hooks = true`. |
| `Skipped loading skill ... invalid YAML` | Pull the latest repo, run `bash install.sh --en`, then restart Codex. |
| Missing integration tool | Run `brew bundle --file Brewfile.codex`. Some checks auto-skip when tools are missing. |
| `mgrep` missing | Run `npm install -g @mixedbread/mgrep`, then use `mgrep login` and `mgrep install-codex` when needed. |
| Tavily/Exa key missing | Set `TAVILY_API_KEY`, `EXA_API_KEY`, or keep existing credentials in `~/.mcp.json`. |
| `az` not logged in | Run `az login`, then confirm the active subscription with `az account show`. |
| Hooks are not Active | Restart Codex, then confirm matching Installed and Active counts in `/hooks`. |

## Work Docs Rule

Every coding task should reconcile `docs/harness/` with the actual diff and verification outcome before the final response.

| Document | What to record |
|----------|----------------|
| `TASKS.md` | Current scope and status |
| `CHANGELOG.md` | Implementation changes |
| `DECISIONS.md` | Decisions and rationale |
| `VALIDATION.md` | Checks run, skipped checks, evidence |
| `RISKS.md` | Open risks, follow-ups, major errors |

## License

MIT
