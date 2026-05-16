# Infra Spec

## Resources

- Codex Lattice itself does not provision cloud resources.
- The `azure_infra` custom agent records durable Azure findings in `.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md`.

## Configuration

- Installer writes Codex configuration under `~/.codex/config.toml`.
- MCP search credentials are read from environment variables first, then from existing `~/.mcp.json` entries.

## Operations And Monitoring

- Hooks record task events, git strategy, commit candidates, major errors, docs sync requirements, and simplify gate requirements.
- Infra changes must include cost, reliability, security, rollback, and monitoring notes before HITL.
