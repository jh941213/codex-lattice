---
name: agent-tool-risk
description: "Agent and tool security review workflow. Use when adding or changing MCP servers, Codex plugins, hooks, sub-agents, tool permissions, prompt flows, automation loops, or model-visible logs."
---

# Agent Tool Risk

Use this skill for MCP, plugins, hooks, sub-agents, tool permissions, prompt flows, automation loops, and model-visible logs.

## Workflow

1. Inventory the agent/tool surface: trigger, command, permissions, inputs, outputs, and persistence.
2. Classify risk:
   - prompt injection or untrusted content
   - excessive agency or destructive authority
   - secret exposure
   - data exfiltration through logs or MCP
   - command injection
   - stale or misleading model-visible memory
3. Confirm high-risk operations have human approval or guard hooks.
4. Ensure hidden logs are not loaded as default model context.
5. Ensure model-visible logs contain only durable, necessary retry context.
6. Update `docs/harness/AGENT_SECURITY.md`, `docs/harness/SECURITY_POLICY.md`, and `docs/harness/SUBAGENT_PROTOCOL.md` if behavior changes.

## Required Output

Return tool surface, risk class, mitigations, required approvals, logging impact, and remaining risks.

## Blockers

- Secrets written to repo, hidden logs, or model-visible memory.
- Mutating cloud or git actions without explicit approval.
- Hooks that execute untrusted user content as shell commands.
- MCP credentials committed or printed.
