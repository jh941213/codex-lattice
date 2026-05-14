# Agent Types (Python)

## Table of contents

- OpenAI Responses agent (basic)
- Azure OpenAI Responses agent (basic)
- Azure OpenAI Responses agent (explicit config)
- Azure OpenAI Chat Completion agent (basic)
- Azure OpenAI Chat Completion agent (explicit config)
- OpenAI Chat Completion agent (explicit config)
- ChatClient-based agent (Azure OpenAI)
- Responses API clients (OpenAI/Azure)
- Azure AI Agent client with function tool
- A2A agent (install)
- A2A agent (resolver + agent card)
- A2A agent (direct URL)
- Custom agent (AgentProtocol)
- Custom agent (BaseAgent)
- Azure AI Foundry agent (basic)
- Azure AI Foundry agent (explicit config)
- Azure AI Foundry agent (persistent)
- Anthropic agent (Foundry)

## OpenAI Responses agent (basic)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/openai-responses-agent

```python
# Add: from agent_framework.openai import OpenAIResponsesClient

async def basic_example():
    # Create an agent using OpenAI Responses
    agent = OpenAIResponsesClient().create_agent(
        name="WeatherBot",
        instructions="You are a helpful weather assistant.",
    )

    result = await agent.run("What's a good way to check the weather?")
    print(result.text)
```

## Azure OpenAI Responses agent (basic)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-openai-responses-agent

```python
import asyncio
from agent_framework.azure import AzureOpenAIResponsesClient
from azure.identity import AzureCliCredential

async def main():
    agent = AzureOpenAIResponsesClient(credential=AzureCliCredential()).create_agent(
        instructions="You are good at telling jokes.",
        name="Joker"
    )

    result = await agent.run("Tell me a joke about a pirate.")
    print(result.text)

asyncio.run(main())
```

## Azure OpenAI Responses agent (explicit config)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-openai-responses-agent

```python
import asyncio
from agent_framework.azure import AzureOpenAIResponsesClient
from azure.identity import AzureCliCredential

async def main():
    agent = AzureOpenAIResponsesClient(
        endpoint="https://<myresource>.openai.azure.com",
        deployment_name="gpt-4o-mini",
        api_version="preview",
        credential=AzureCliCredential()
    ).create_agent(
        instructions="You are good at telling jokes.",
        name="Joker"
    )

    result = await agent.run("Tell me a joke about a pirate.")
    print(result.text)

asyncio.run(main())
```

## Azure OpenAI Chat Completion agent (basic)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-openai-chat-completion-agent

```python
import asyncio
from agent_framework.azure import AzureOpenAIChatClient
from azure.identity import AzureCliCredential

async def main():
    agent = AzureOpenAIChatClient(credential=AzureCliCredential()).create_agent(
        instructions="You are good at telling jokes.",
        name="Joker"
    )

    result = await agent.run("Tell me a joke about a pirate.")
    print(result.text)

asyncio.run(main())
```

## Azure OpenAI Chat Completion agent (explicit config)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-openai-chat-completion-agent

```python
import asyncio
from agent_framework.azure import AzureOpenAIChatClient
from azure.identity import AzureCliCredential

async def main():
    agent = AzureOpenAIChatClient(
        endpoint="https://<myresource>.openai.azure.com",
        deployment_name="gpt-4o-mini",
        credential=AzureCliCredential()
    ).create_agent(
        instructions="You are good at telling jokes.",
        name="Joker"
    )

    result = await agent.run("Tell me a joke about a pirate.")
    print(result.text)

asyncio.run(main())
```

## OpenAI Chat Completion agent (explicit config)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/openai-chat-completion-agent

```python
# Add: from agent_framework.openai import OpenAIChatClient

async def explicit_config_example():
    agent = OpenAIChatClient(
        ai_model_id="gpt-4o-mini",
        api_key="your-api-key-here",
    ).create_agent(
        instructions="You are a helpful assistant.",
    )

    result = await agent.run("What can you do?")
    print(result.text)
```

## ChatClient-based agent (Azure OpenAI)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/chat-client-agent

```python
from agent_framework import ChatAgent
from agent_framework.azure import AzureOpenAIChatClient

# Create agent using Azure OpenAI
agent = ChatAgent(
    chat_client=AzureOpenAIChatClient(
        model_id="gpt-4o",
        endpoint="https://your-resource.openai.azure.com/",
        api_key="your-api-key"
    ),
    instructions="You are a helpful assistant.",
    name="Azure OpenAI Assistant"
)
```

## Responses API clients (OpenAI/Azure)

Source: https://learn.microsoft.com/en-us/agent-framework/migration-guide/from-autogen/index

```python
from agent_framework.azure import AzureOpenAIResponsesClient
from agent_framework.openai import OpenAIResponsesClient

# Azure OpenAI with Responses API
azure_responses_client = AzureOpenAIResponsesClient(model_id="gpt-5")

# OpenAI with Responses API
openai_responses_client = OpenAIResponsesClient(model_id="gpt-5")
```

## Azure AI Agent client with function tool

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types

```python
from typing import Annotated
from pydantic import Field
from azure.identity.aio import DefaultAzureCredential
from agent_framework.azure import AzureAIAgentClient


def get_weather(location: Annotated[str, Field(description="The location to get the weather for.")]) -> str:
    """Get the weather for a given location."""
    return f"The weather in {location} is sunny with a high of 25°C."

async with (
    DefaultAzureCredential() as credential,
    AzureAIAgentClient(async_credential=credential).create_agent(
        instructions="You are a helpful weather assistant.",
        tools=get_weather
    ) as agent
):
    response = await agent.run("What's the weather in Seattle?")
```

## A2A agent (install)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/a2a-agent

```bash
pip install agent-framework-a2a --pre
```

## A2A agent (resolver + agent card)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/a2a-agent

```python
import httpx
from a2a.client import A2ACardResolver
from agent_framework.a2a import A2AAgent

# Create httpx client for HTTP communication
async with httpx.AsyncClient(timeout=60.0) as http_client:
    resolver = A2ACardResolver(httpx_client=http_client, base_url="https://your-a2a-agent-host")

    # Get agent card from the well-known location
    agent_card = await resolver.get_agent_card(relative_card_path="/.well-known/agent.json")

    # Create A2A agent instance
    agent = A2AAgent(
        name=agent_card.name,
        description=agent_card.description,
        agent_card=agent_card,
        url="https://your-a2a-agent-host"
    )
```

## A2A agent (direct URL)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/a2a-agent

```python
from agent_framework.a2a import A2AAgent

agent = A2AAgent(
    name="My A2A Agent",
    description="A directly configured A2A agent",
    url="https://your-a2a-agent-host/echo"
)
```

## Custom agent (AgentProtocol)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/custom-agent

```python
from agent_framework import AgentProtocol, AgentRunResponse, AgentRunResponseUpdate, AgentThread, ChatMessage
from collections.abc import AsyncIterable
from typing import Any

class MyCustomAgent(AgentProtocol):
    @property
    def id(self) -> str:
        ...

    async def run(
        self,
        messages: str | ChatMessage | list[str] | list[ChatMessage] | None = None,
        *,
        thread: AgentThread | None = None,
        **kwargs: Any,
    ) -> AgentRunResponse:
        ...

    def run_stream(
        self,
        messages: str | ChatMessage | list[str] | list[ChatMessage] | None = None,
        *,
        thread: AgentThread | None = None,
        **kwargs: Any,
    ) -> AsyncIterable[AgentRunResponseUpdate]:
        ...
```

## Custom agent (BaseAgent)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/custom-agent

```python
from agent_framework import BaseAgent, AgentRunResponse, AgentRunResponseUpdate, AgentThread, ChatMessage
from collections.abc import AsyncIterable
from typing import Any

class CustomAgent(BaseAgent):
    async def run(
        self,
        messages: str | ChatMessage | list[str] | list[ChatMessage] | None = None,
        *,
        thread: AgentThread | None = None,
        **kwargs: Any,
    ) -> AgentRunResponse:
        # Custom agent implementation
        ...

    def run_stream(
        self,
        messages: str | ChatMessage | list[str] | list[ChatMessage] | None = None,
        *,
        thread: AgentThread | None = None,
        **kwargs: Any,
    ) -> AsyncIterable[AgentRunResponseUpdate]:
        # Custom streaming implementation
        ...
```

## Azure AI Foundry agent (basic)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-ai-foundry-agent

```python
import asyncio
from agent_framework.azure import AzureAIAgentClient
from azure.identity.aio import AzureCliCredential

async def main():
    async with (
        AzureCliCredential() as credential,
        AzureAIAgentClient(async_credential=credential).create_agent(
            name="HelperAgent",
            instructions="You are a helpful assistant."
        ) as agent,
    ):
        result = await agent.run("Hello!")
        print(result.text)

asyncio.run(main())
```

## Azure AI Foundry agent (explicit config)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-ai-foundry-agent

```python
import asyncio
from agent_framework.azure import AzureAIAgentClient
from azure.identity.aio import AzureCliCredential

async def main():
    async with (
        AzureCliCredential() as credential,
        AzureAIAgentClient(
            project_endpoint="https://<your-project>.services.ai.azure.com/api/projects/<project-id>",
            model_deployment_name="gpt-4o-mini",
            async_credential=credential,
            agent_name="HelperAgent"
        ).create_agent(
            instructions="You are a helpful assistant."
        ) as agent,
    ):
        result = await agent.run("Hello!")
        print(result.text)

asyncio.run(main())
```

## Azure AI Foundry agent (persistent)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-ai-foundry-agent

```python
import asyncio
import os
from agent_framework import ChatAgent
from agent_framework.azure import AzureAIAgentClient
from azure.ai.projects.aio import AIProjectClient
from azure.identity.aio import AzureCliCredential

async def main():
    async with (
        AzureCliCredential() as credential,
        AIProjectClient(
            endpoint=os.environ["AZURE_AI_PROJECT_ENDPOINT"],
            credential=credential
        ) as project_client,
    ):
        created_agent = await project_client.agents.create_agent(
            model=os.environ["AZURE_AI_MODEL_DEPLOYMENT_NAME"],
            name="PersistentAgent",
            instructions="You are a helpful assistant."
        )

        try:
            async with ChatAgent(
                chat_client=AzureAIAgentClient(
                    project_client=project_client,
                    agent_id=created_agent.id
                ),
                instructions="You are a helpful assistant."
            ) as agent:
                result = await agent.run("Hello!")
                print(result.text)
        finally:
            await project_client.agents.delete_agent(created_agent.id)

asyncio.run(main())
```

## Anthropic agent (Foundry)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/anthropic-agent

```python
from agent_framework.anthropic import AnthropicClient
from anthropic import AsyncAnthropicFoundry

async def foundry_example():
    agent = AnthropicClient(
        anthropic_client=AsyncAnthropicFoundry()
    ).create_agent(
        name="FoundryAgent",
        instructions="You are a helpful assistant using Anthropic on Foundry.",
    )

    result = await agent.run("How do I use Anthropic on Foundry?")
    print(result.text)
```
