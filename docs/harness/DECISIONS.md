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
- reason: one config registration path is easier to verify and avoids 15 hook registrations becoming 30 inside this repository.
- impact: users must run `bash install.sh --ko` or `bash install.sh --en`; plugin metadata and installer remain the supported entry points.
