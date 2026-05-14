---
name: microsoft-agent-framework
description: Build, configure, and troubleshoot Microsoft Agent Framework (agent-framework repo) in Python, including ChatAgent setup, OpenAI/Azure clients, tool/function calling, multi-agent workflows, and environment setup. Use when requests mention Agent Framework, ChatAgent, OpenAIChatClient, AzureOpenAIResponsesClient, WorkflowBuilder, or Python agent setup.
---

# Microsoft Agent Framework

## Overview

Use this skill to implement or explain Microsoft Agent Framework usage in Python. Prefer Microsoft Learn docs for conceptual guidance and use Context7 to fetch exact snippets (package extras, Azure/OpenAI client specifics).

## Workflow

1) Identify runtime and provider
- Confirm Python.
- Pick provider: OpenAI, Azure OpenAI, or Azure AI Foundry.
- Confirm required environment variables before coding.

2) Install and configure
- Use pip packages and extras for the provider you need.
- Load env vars from the shell or a `.env` file.

3) Create a basic agent
- Choose an agent type: `ChatAgent`, `OpenAIResponsesClient`, `AzureOpenAIResponsesClient`, or `AzureAIAgentClient` (Azure AI).
- Use `OpenAIChatClient` (OpenAI) or `AzureOpenAIResponsesClient` (Azure OpenAI) for common setups.
- Start with non-streaming, then add streaming if needed.

4) Add tools and functions
- Python: pass callables via `tools=[...]` on `ChatAgent` or per request.
- Use `HostedCodeInterpreterTool` when you need sandboxed Python execution.
- Use `@ai_function(approval_mode="always_require")` for human approvals and handle `user_input_requests`.

5) Orchestrate multi-agent workflows
- Use `WorkflowBuilder` and edges for simple graphs.
- Use fan-out/fan-in and branching edge groups when you need concurrency or routing.
- Use `SequentialBuilder` for pipeline workflows and `workflow.as_agent()` when you need a workflow to behave like a single agent.
- Use `MagenticBuilder` for manager/participant orchestration (advanced).
- Inspect `AgentRunEvent` outputs to debug.

6) Integrate external tools via MCP
- Use `HostedMCPTool` for Microsoft Learn MCP.
- Use `MCPStreamableHTTPTool` for HTTP/SSE MCP servers.

7) Add memory and storage
- Serialize/deserialize threads for persistence.
- Use a memory provider or chat message store for long-term history.

8) Add middleware
- Use agent-level middleware for cross-cutting concerns (logging, security).
- Add run-level middleware when behavior is per-request.

9) Integrate AG-UI (optional)
- Use AG-UI for web clients, streaming, state management, and human approvals.

## Context7 usage

- Preferred library id: `/microsoft/agent-framework`
- Alternative docs: `/websites/learn_microsoft_en-us_agent-framework`
- Example queries:
  - "OpenAIChatClient ChatAgent Python example"
  - "AzureOpenAIResponsesClient Python example"
  - "running agents run_stream Python"
  - "multi-turn conversation agent threads Python"
  - "WorkflowBuilder Python example"
  - "HostedMCPTool MCPStreamableHTTPTool Python example"
  - "SequentialBuilder workflow as_agent"
  - "AzureAIAgentClient agent types Python"

## References

- `references/quickstart.md`
- `references/env-vars.md`
- `references/agent-types.md`
- `references/tools.md`
- `references/function-tools-approvals.md`
- `references/running-agents.md`
- `references/agents-images.md`
- `references/agents-structured-output.md`
- `references/agents-as-mcp-tool.md`
- `references/agents-as-tool.md`
- `references/agents-memory.md`
- `references/agent-rag.md`
- `references/agent-middleware.md`
- `references/mcp-overview.md`
- `references/mcp-tools.md`
- `references/ag-ui.md`
- `references/workflows.md`
- `references/workflow-tutorials.md`
- `references/workflow-core.md`
- `references/orchestrations.md`
- `references/requests-responses.md`
- `references/checkpointing.md`
- `references/magentic.md`
- `references/shared-states.md`
- `references/workflow-observability.md`
- `references/workflow-visualization.md`
- `references/workflow-state-isolation.md`
- `references/devui.md`
- `references/observability.md`
