# Test Plan

## Unit

- Parse JSON/TOML/YAML metadata.
- Validate hook scripts with shell syntax checks.

## Integration

- Run installer against a temporary `CODEX_HOME`.
- Confirm skill, agent, hook, MCP, and feature registrations.

## E2E

- Restart Codex, review hooks, and confirm installed hooks become active.

## Regression

- Old managed config blocks should be removed on reinstall.
- Removed legacy agent paths should not reappear.

## Manual Checks

- Confirm `/hooks`, `/mcp`, and selected skills behave as documented.
