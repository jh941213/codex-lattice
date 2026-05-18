# Decisions

## 2026-05-14 - Codex-only repository

- context: The public repository should contain only the reusable Codex harness setup, not the source conversion workspace.
- decision: publish a clean whitelist export containing Codex config, plugin metadata, skills, agents, hooks, rules, docs, installer, integration checker, and runtime memory templates.
- reason: users should be able to clone one small harness repo and install it without unrelated conversion artifacts.
- impact: release changes should be made in this clean repo shape.

## 2026-05-14 - Built-ins first

- context: Codex already provides `/goal`, `/plan`, `/review`, `/diff`, `/compact`, `/agent`, `/debug-config`, `/plugins`, and `/mcp`.
- decision: prefer Codex built-ins where sufficient; use skills and custom agents for durable workflows or specialized review.
- reason: duplicated command systems make routing harder and drift faster.
- impact: no `&goal` alias or legacy command folder is installed.

## 2026-05-14 - Azure Infra is a read-only-first agent

- context: Azure operations can affect cost, availability, and security.
- decision: `azure_infra` defaults to read-only `az` discovery and records durable notes in `.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md`.
- reason: infrastructure agents need explicit blast-radius control and memory across sessions.
- impact: mutating Azure operations require explicit user approval and must include cost, security, reliability, rollback, and monitoring notes.

## 2026-05-14 - Search MCP uses env-first credential fallback

- context: Existing local MCP config already has Tavily and Exa credentials, but public harness files must not contain secrets.
- decision: configure Tavily and Exa MCP through Codex with commands that read `TAVILY_API_KEY`/`EXA_API_KEY` first and fall back to `~/.mcp.json`.
- reason: this keeps the repo secret-free while preserving existing user search integrations.
- impact: users can bring their own env vars or reuse existing MCP credentials without editing repo files.

## 2026-05-15 - Distribution name is Codex Lattice

- context: The original repository name was too literal and still looked tied to the source conversion workspace.
- decision: use `codex-lattice` as the public repository, plugin name, README title, clone path, and project-local runtime folder `.codex-lattice/`.
- reason: the package is a reusable Codex coordination layer, not a one-off conversion of the old harness repository.
- impact: installer output, plugin metadata, docs, ignored runtime files, hook writes, and autodev state now use the `codex-lattice` identity. The installer still removes the prior managed config block during migration.

## 2026-05-15 - Installer owns Codex config registration

- context: Keeping a repo-local `.codex/config.toml` duplicates the user-level registrations written by `install.sh`, causing duplicate hook review prompts and stale agent paths when the repo is opened directly in Codex.
- decision: remove `.codex/config.toml` from the distribution and keep only `.codex/agents/*.toml` as reusable agent role files.
- reason: one config registration path is easier to verify and avoids duplicate hook registrations inside this repository.
- impact: users must run `bash install.sh --ko` or `bash install.sh --en`; plugin metadata and installer remain the supported entry points.

## 2026-05-16 - HITL requires simplify and docs gates

- context: Human review should not receive code that still needs obvious simplification, normalization, or documentation reconciliation.
- decision: add advisory model-visible gates for simplification and docs maintenance before HITL, review, PR, or final response.
- reason: hooks should not rewrite code automatically, but they can create durable prompts that force the parent agent or a docs sub-agent to finish the pre-review work.
- impact: `codex-simplify-gate.sh` writes `SIMPLIFY_REQUIRED.md`; docs sync writes `DOCS_AGENT_REQUIRED.md` and classifies required docs. The parent agent remains responsible for spawning `docs_maintainer` when the current Codex run allows sub-agents, otherwise it updates the docs directly.

## 2026-05-16 - Docs cover PRD-adjacent development context

- context: Feature/API/infra docs alone miss security, data, test, observability, operations response, migration, release, UX, and pre-PRD product context.
- decision: keep dedicated docs under `docs/harness/` for product brief, feature spec, API spec, infra spec, security policy, data model, test plan, observability, operations runbook, migration plan, release plan, and UX spec.
- reason: these documents let implementation details feed back into PRD and review decisions without relying on hidden session memory.
- impact: docs gate requirements expand based on changed file paths and extensions; stale docs must be resolved before HITL unless blocked and recorded in `RISKS.md`.

## 2026-05-16 - Reflection gate controls instruction drift

- context: Long Codex sessions can drift when users give several ordered instructions, interrupt a workflow, or resume after compaction.
- decision: add `docs/harness/REFLECTION.md` and a `codex-reflection-reminder.sh` hook that creates `REFLECTION_REQUIRED.md` for complex sequential prompts, post-compact resume, and Stop reminders.
- reason: direction checks should be explicit, model-visible, and repeatable instead of relying on hidden conversation memory.
- impact: before HITL, PR, merge, or final response, the agent must confirm the newest request, ordered steps, dependencies, blocked items, validation, and git status.

## 2026-05-16 - Sub-agents use bounded Codex-native delegation

- context: External agent workflows show that fresh sub-agents work best when the parent controls context, task boundaries, and review loops instead of relying on inherited session memory.
- decision: add `docs/harness/SUBAGENT_PROTOCOL.md` and summarize the protocol in `AGENTS.md` and README files.
- reason: Codex Lattice already has native custom agents and multi-agent support; the missing piece was a consistent contract for prompt context, task status, review order, and parallel ownership.
- impact: parent agents must provide full task context directly, require `DONE`/`DONE_WITH_CONCERNS`/`NEEDS_CONTEXT`/`BLOCKED` statuses, verify claims against the actual diff, and run spec compliance review before code quality review when sub-agents write code.

## 2026-05-18 - Operations governance skills are first-class workflows

- context: Real-world development needs more than implementation, review, and tests; release handoff, incidents, SLOs, supply chain, tool risk, data governance, and cloud cost create operational risk.
- decision: add dedicated skills and docs for release readiness, incident response, observability/SLO, supply-chain security, agent tool risk, Azure FinOps, data governance, and postmortems.
- reason: these workflows should be repeatable and visible before PR, deploy, or HITL instead of depending on ad hoc memory.
- impact: docs sync can request `SLO_POLICY.md`, `INCIDENT_RESPONSE.md`, `POSTMORTEM_TEMPLATE.md`, `SUPPLY_CHAIN.md`, `AGENT_SECURITY.md`, `DATA_GOVERNANCE.md`, and `COST_MODEL.md` when changed files imply operational governance work.

## 2026-05-18 - Runtime files resolve the git root

- context: Hooks can run from subdirectories, which can fragment `.codex-lattice` logs and model-visible error memory.
- decision: resolve `git rev-parse --show-toplevel` before writing event logs, major error logs, and visible error reminders.
- reason: future agents need one durable runtime surface per repository.
- impact: project-local `.codex-lattice/` files are written at the repository root when the current directory is inside a git worktree.

## 2026-05-18 - Installer replaces active hook scripts atomically

- context: Codex hooks can run while the harness is being reinstalled, so direct `cp` can expose a partially written shell script to an active hook process.
- decision: copy hook and script files to temporary files and replace them with `mv` after the copy completes.
- reason: active hook reads should see either the previous complete script or the next complete script, never a truncated intermediate file.
- impact: reinstall is safer while Codex is running, though users should still restart Codex after config changes.

## 2026-05-18 - Scheduled operations are external and opt-in

- context: Codex CLI has non-interactive `codex exec`, but no built-in cron scheduler.
- decision: implement scheduled operations as local scripts plus external scheduler templates, with macOS launchd enable/disable/status controls.
- reason: scheduling is an operating-system concern, while Codex should stay read-only and advisory during routine health reports.
- impact: default scheduled checks are deterministic and model-free; `CODEX_LATTICE_USE_CODEX=1` enables optional read-only Codex summary generation.

## 2026-05-18 - Context and review packets are advisory evidence

- context: Agents need compact task context, review evidence, and harness health signals without loading hidden logs or entire docs trees by default.
- decision: generate `CONTEXT_PACKET.md`, `REVIEW_PACKET.md`, `HARNESS_HEALTH.md`, and per-run packet snapshots from read-only local metadata.
- reason: this follows the context-engineering pattern of giving the model the smallest useful reading path, while keeping verification tied to files and command output.
- impact: packet scripts run on selected Codex lifecycle hooks, write only under `.codex-lattice/`, exclude sensitive path candidates, and remain advisory rather than source of truth.
