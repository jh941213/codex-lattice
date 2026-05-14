# Model Context Protocol (MCP) Overview

## Table of contents

- MCP tool types (stdlib, HTTP, websocket)
- MCP with Foundry agents (concepts)

## MCP tool types (stdlib, HTTP, websocket)

Source: https://learn.microsoft.com/en-us/agent-framework/migration-guide/from-autogen

```python
from agent_framework import ChatAgent, MCPStdioTool, MCPStreamableHTTPTool, MCPWebsocketTool
from agent_framework.openai import OpenAIChatClient
```

Note: See `references/mcp-tools.md` for runnable examples.

## MCP with Foundry agents (concepts)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/model-context-protocol/using-mcp-with-foundry-agents

Key points:
- Foundry hosts MCP servers and manages tool execution.
- Agents can use hosted MCP tools with approval workflows.
- Persistent agents enable stateful conversations across tool calls.
