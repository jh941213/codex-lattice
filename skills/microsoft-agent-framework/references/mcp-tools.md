# MCP Tools (Python)

## Table of contents

- HostedMCPTool for Microsoft Learn
- HostedMCPTool approval_mode (auto vs require)
- MCPStreamableHTTPTool (HTTP/SSE)
- MCP tool definition (Foundry agents)

## HostedMCPTool for Microsoft Learn

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-tools

```python
from agent_framework import HostedMCPTool

agent = ChatAgent(
    chat_client=AzureAIAgentClient(async_credential=credential),
    instructions="You are a documentation assistant",
    tools=[
        HostedMCPTool(
            name="Microsoft Learn MCP",
            url="https://learn.microsoft.com/api/mcp"
        )
    ]
)

result = await agent.run("How do I create an Azure storage account?")
```

Note: Add the relevant `ChatAgent` and `AzureAIAgentClient` imports for your setup.

## HostedMCPTool approval_mode (auto vs require)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/model-context-protocol/using-mcp-with-foundry-agents

```python
async def multi_tool_mcp_example():
    """Example using multiple hosted MCP tools."""
    async with (
        AzureCliCredential() as credential,
        AzureAIAgentClient(async_credential=credential) as chat_client,
    ):
        await chat_client.setup_azure_ai_observability()

        # Create agent with multiple MCP tools
        agent = chat_client.create_agent(
            name="MultiToolAgent",
            instructions="You can search documentation and access GitHub repositories.",
            tools=[
                HostedMCPTool(
                    name="Microsoft Learn MCP",
                    url="https://learn.microsoft.com/api/mcp",
                    approval_mode="never_require",
                ),
                HostedMCPTool(
                    name="GitHub MCP",
                    url="https://api.github.com/mcp",
                    approval_mode="always_require",
                    headers={"Authorization": "Bearer github-token"},
                ),
            ],
        )

        result = await agent.run(
            "Find Azure documentation and also check the latest commits in microsoft/semantic-kernel"
        )
        print(result)

if __name__ == "__main__":
    asyncio.run(multi_tool_mcp_example())
```

## MCPStreamableHTTPTool (HTTP/SSE)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/model-context-protocol/using-mcp-tools

```python
import asyncio
from agent_framework import ChatAgent, MCPStreamableHTTPTool
from agent_framework.azure import AzureAIAgentClient
from azure.identity.aio import AzureCliCredential

async def http_mcp_example():
    """Example using an HTTP-based MCP server."""
    async with (
        AzureCliCredential() as credential,
        MCPStreamableHTTPTool(
            name="Microsoft Learn MCP",
            url="https://learn.microsoft.com/api/mcp",
            headers={"Authorization": "Bearer your-token"},
        ) as mcp_server,
        ChatAgent(
            chat_client=AzureAIAgentClient(async_credential=credential),
            name="DocsAgent",
            instructions="You help with Microsoft documentation questions.",
        ) as agent,
    ):
        result = await agent.run(
            "How to create an Azure storage account using az cli?",
            tools=mcp_server
        )
        print(result)

if __name__ == "__main__":
    asyncio.run(http_mcp_example())
```

## MCP tool definition (Foundry agents)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/model-context-protocol/using-mcp-with-foundry-agents

```python
mcp_tool = {
    "server_label": "microsoft_learn",
    "server_url": "https://learn.microsoft.com/api/mcp",
    "allowed_tools": ["microsoft_docs_search"],
}
```
