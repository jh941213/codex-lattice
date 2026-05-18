# Codex Lattice

This repository now includes a Codex-native harness layer.

## Install

```bash
git clone https://github.com/jh941213/codex-lattice.git
cd codex-lattice
bash install.sh --ko
```

Restart Codex after installation so `~/.codex/config.toml` is reloaded.

## What Gets Installed

- `~/.codex/skills/`: bundled skills
- `~/.codex/hooks/codex-*.sh`: lifecycle hooks
- `~/.codex/agents/`: Codex custom agent TOML files
- `.codex/agents/*.toml`: Codex-native custom agent configuration. Markdown role files are intentionally not installed.
- `~/.codex/config.toml`: managed Codex config entries
- `~/.codex/harness/model-visible/AZURE_INFRA_MEMORY.md`: Azure infrastructure memory template

## Codex Config Surfaces

- Skills: copied into `~/.codex/skills/` and registered with `[[skills.config]]`
- Custom hooks: enabled with `[features].hooks` and registered under `[hooks]` in `~/.codex/config.toml`
- Goals: enabled with `[features].goals`; use `/goal <objective>` for long-running work instead of custom restart loops
- Sub-agents: registered under `[agents.<role>]` with `config_file`; each file also includes Codex custom agent fields (`name`, `description`, `developer_instructions`)
- Plugin metadata: `.codex-plugin/plugin.json`
- Marketplace metadata: `.agents/plugins/marketplace.json`

## Built-ins First

- Codex built-ins use `/goal`-style commands. Harness skills use `$prd`-style skill names. No `&goal` aliases are installed.
- `/goal`: keep the objective and done condition attached to long-running work; mirror progress in `docs/harness/TASKS.md`.
- `/plan`: use for short-lived planning; create durable plan docs only when the work needs handoff or audit history.
- `/review` and `/diff`: use before heavier review skills or custom agents.
- `/compact`, `/status`, `/ps`, `/stop`: use for context and process management before custom scripts.
- `/agent`, `/plugins`, `/mcp`, `/debug-config`: use for sub-agent, plugin, MCP, and config inspection.

## Runtime Logs

Project-local runtime files are written under `.codex-lattice/`.

- `.codex-lattice/logs/events.jsonl`: hidden hook/event stream
- `.codex-lattice/git-strategy.md`: task-level Git strategy entries
- `.codex-lattice/commits/*.json`: commit metadata
- `.codex-lattice/commits/*.md`: human-readable commit log
- `.codex-lattice/model-visible/MAJOR_ERRORS.md`: blocking/repeated errors that the model should read
- `.codex-lattice/docs-sync-queue.jsonl`: changed-file queue for docs maintenance

## Model-Visible Work Docs

Sub-agents should keep `docs/harness/` synchronized with implementation work.

- `docs/harness/TASKS.md`: current scope and status
- `docs/harness/DECISIONS.md`: decisions and rationale
- `docs/harness/CHANGELOG.md`: implementation changes
- `docs/harness/VALIDATION.md`: checks run and skipped checks
- `docs/harness/RISKS.md`: open risks and major errors
- `docs/harness/SLO_POLICY.md`: SLOs, error budgets, and alert policy
- `docs/harness/INCIDENT_RESPONSE.md`: severity, triage, mitigation, and communication
- `docs/harness/POSTMORTEM_TEMPLATE.md`: blameless incident review template
- `docs/harness/SUPPLY_CHAIN.md`: dependency, SBOM, provenance, and vulnerability policy
- `docs/harness/AGENT_SECURITY.md`: MCP, hook, plugin, and sub-agent risk controls
- `docs/harness/DATA_GOVERNANCE.md`: classification, privacy, retention, and access controls
- `docs/harness/COST_MODEL.md`: budget, cloud cost drivers, and Azure resource review

Before finalizing coding work, reconcile these docs with `git diff`; use `docs_maintainer` only when Codex agent delegation is explicitly allowed for the run.

## Sub-Agent Roles

- `planner`: implementation plans, acceptance criteria, risks, validation.
- `architect`: module boundaries, dependencies, migration risk.
- `frontend_developer`: React/TypeScript/Tailwind UI implementation.
- `junior_mentor`: beginner-friendly learning notes for implemented work.
- `prd_planner`: CPS/PRD/SPEC planning synthesis.
- `code_reviewer`: correctness, regressions, missing tests.
- `security_reviewer`: secrets, auth, input validation, dependency risk.
- `qa`: user scenarios and verification checklists.
- `evaluator`: independent result scoring and fix-forward loops.
- `docs_writer`: durable docs and handoff notes.
- `docs_maintainer`: `docs/harness/` synchronization after implementation changes.
- `azure_infra`: Azure CLI based sizing, resource review, operations, monitoring, and Azure memory updates.
- `tdd_guide`: test-first planning.
- `stitch_developer`: Stitch-to-React conversion.
