# Agent Security

Use this file when MCP servers, hooks, plugins, skills, sub-agents, automation loops, or model-visible memory change.

## Tool Trust Boundaries

- Tool:
- Trigger:
- Input source:
- Output destination:
- Permissions:

## Prompt Injection Risks

- Untrusted content source:
- Isolation strategy:
- Model-visible persistence:
- Required validation:

## Excessive Agency Controls

- Read-only by default:
- Human approval required for:
- Guard hooks:
- Rollback path:

## Secret Exposure Controls

- Secrets must not be committed, logged, printed, or written to model-visible files.
- MCP credentials should come from environment variables or existing local config.
- Redact tokens, keys, connection strings, and credentials in reports.

## Review Checklist

- Commands quote user-controlled paths and IDs.
- Hooks do not execute untrusted model text as shell.
- Hidden logs are not read as default context.
- Model-visible logs contain only durable retry context.
