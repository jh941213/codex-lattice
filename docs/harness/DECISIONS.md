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
- decision: `azure_infra` defaults to read-only `az` discovery and records durable notes in `.codex-harness/model-visible/AZURE_INFRA_MEMORY.md`.
- reason: infrastructure agents need explicit blast-radius control and memory across sessions.
- impact: mutating Azure operations require explicit user approval and must include cost, security, reliability, rollback, and monitoring notes.

## 2026-05-14 - Search MCP uses env-first credential fallback

- context: Existing local MCP config already has Tavily and Exa credentials, but public harness files must not contain secrets.
- decision: configure Tavily and Exa MCP through Codex with commands that read `TAVILY_API_KEY`/`EXA_API_KEY` first and fall back to `~/.mcp.json`.
- reason: this keeps the repo secret-free while preserving existing user search integrations.
- impact: users can bring their own env vars or reuse existing MCP credentials without editing repo files.
