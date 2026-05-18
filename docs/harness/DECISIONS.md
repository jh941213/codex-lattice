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
