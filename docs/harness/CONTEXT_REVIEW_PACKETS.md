# Context Review Packets

Codex Lattice creates small model-visible packet files so Codex can inspect the right evidence without loading hidden runtime logs by default.

## Files

- `.codex-lattice/model-visible/CONTEXT_PACKET.md`
- `.codex-lattice/model-visible/REVIEW_PACKET.md`
- `.codex-lattice/model-visible/HARNESS_HEALTH.md`
- `.codex-lattice/runs/<session>/context-packet.md`
- `.codex-lattice/runs/<session>/review-packet.md`

## Context Packet

Generated on `UserPromptSubmit` and `PostCompact`.

Purpose:

- summarize current branch, dirty state, recent commits, and changed files
- include unstaged, staged, and untracked files in changed-file routing
- list required reading candidates from `docs/harness/` and model-visible gates
- list validation command candidates from project scripts and common stack files
- remind the agent which retrieval tool to use: `rg`, `sg`, `mgrep`, Tavily, Exa, or OpenAI docs

Rules:

- The packet is a routing aid, not source of truth.
- The agent must verify claims against files and command output.
- Sensitive paths such as `.env`, tokens, credentials, private keys, `.pem`, and `.key` are excluded from reading candidates.

## Review Packet

Generated on `PermissionRequest` and `Stop`.

Purpose:

- summarize changed files and diff size
- list untracked files separately so newly created API, infra, hook, or security-sensitive files are not missed before staging
- classify risk by file path: security, API, infra, UI, data, supply chain, agent/tool, scheduler/ops
- show gate status for major errors, docs, simplify, context, and harness health
- surface latest healthcheck/log-analysis report summaries
- provide a review checklist before HITL, PR, or final response

Rules:

- High-risk categories must be reviewed before style cleanup.
- Hidden logs are evidence, not source of truth.
- The parent agent must still inspect the actual diff.

## Harness Health

Generated on `UserPromptSubmit` and `Stop`.

Purpose:

- summarize local Codex install counts and feature flags
- check runtime event log shape and docs queue count
- show model-visible gate presence
- show scheduler installed/active status
- list latest generated reports

Rules:

- Health output is advisory.
- If `MAJOR_ERRORS.md`, `DOCS_AGENT_REQUIRED.md`, or `SIMPLIFY_REQUIRED.md` is present, the agent should inspect and resolve the gate before final review.

## Safety

- Packet scripts do not execute user prompt text.
- Packet scripts do not mutate source code, git history, cloud resources, or external services.
- Packet scripts write only under `.codex-lattice/`.
- Packet scripts do not print or persist secrets.
