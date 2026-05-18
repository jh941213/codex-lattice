# Agent Security

Use this file when MCP servers, hooks, plugins, skills, sub-agents, automation loops, or model-visible memory change.

## Tool Trust Boundaries

- Tool: context/review/health packet scripts
- Trigger: `UserPromptSubmit`, `PostCompact`, `PermissionRequest`, `Stop`
- Input source: Codex hook JSON, git metadata, local project files, generated `.codex-lattice` reports
- Output destination: `.codex-lattice/model-visible/*.md`, `.codex-lattice/runs/<session>/`
- Permissions: local read plus writes under `.codex-lattice/`

## Prompt Injection Risks

- Untrusted content source: user prompts, filenames, README/docs content, package scripts, generated reports
- Isolation strategy: packet scripts summarize metadata and do not execute prompt text or package scripts
- Model-visible persistence: packet files are advisory routing aids, not source of truth
- Required validation: verify claims against files, git diff, and command output before acting

## Excessive Agency Controls

- Read-only by default: packet scripts observe and summarize only
- Human approval required for: destructive git, cloud mutation, permission changes, release, or external publication
- Guard hooks: `codex-git-guard.sh`, simplify/docs/reflection gates, review packet risk routing
- Rollback path: delete `.codex-lattice/model-visible/*PACKET.md` or rerun packet generation after correcting state

## Secret Exposure Controls

- Secrets must not be committed, logged, printed, or written to model-visible files.
- MCP credentials should come from environment variables or existing local config.
- Redact tokens, keys, connection strings, and credentials in reports.

## Review Checklist

- Commands quote user-controlled paths and IDs.
- Hooks do not execute untrusted model text as shell.
- Hidden logs are not read as default context.
- Model-visible logs contain only durable retry context.
