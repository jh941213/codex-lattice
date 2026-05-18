# Security Policy

## Trust Boundaries

- Hooks and installer run locally under the user's Codex environment.
- MCP credentials are read from environment variables or existing local `~/.mcp.json`; this repository must not contain secrets.

## Auth And Authorization

- Azure operations default to read-only discovery unless the user explicitly approves a scoped mutating operation.
- Destructive git operations are blocked by hook policy.

## Data Handling

- Hidden logs are operational traces and should not be loaded into model context by default.
- Model-visible files are limited to durable retry context, gate requirements, context/review/health packets, and durable infra assumptions.
- Context/review/health packets summarize metadata and local file paths, including untracked path-level routing for review; they do not include secret file contents.

## Secret Handling

- `.env`, keys, credentials, tokens, and connection strings must not be committed.
- Packet generation excludes sensitive path candidates such as `.env`, tokens, credentials, private keys, `.pem`, and `.key` from required-reading candidates.
- Review packets may mention sensitive paths such as `.env` as security-routing evidence, but must not print or persist their contents.
- Run `gitleaks` before release or PR.

## Abuse And Failure Modes

- If a security issue is found, pause feature work, document the risk, and run security review before HITL.
- MCP, hook, plugin, sub-agent, prompt injection, and excessive-agency risks are tracked in `AGENT_SECURITY.md`.
- Dependency, SBOM, provenance, and vulnerability decisions are tracked in `SUPPLY_CHAIN.md`.
- PII, retention, privacy, access, and audit decisions are tracked in `DATA_GOVERNANCE.md`.
