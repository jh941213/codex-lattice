# Tools and Function Calling (Python)

## Table of contents

- ChatAgent tools (OpenAIChatClient)
- Tools per run (dynamic tools)
- OpenAI Responses agent with tools
- Azure OpenAI Responses agent with tools
- ChatAgent tools (Azure OpenAI Responses)

## ChatAgent tools (OpenAIChatClient)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-tools

```python
from typing import Annotated
from pydantic import Field
from agent_framework import ChatAgent
from agent_framework.openai import OpenAIChatClient

# Sample function tool
def get_weather(
    location: Annotated[str, Field(description="The location to get the weather for.")],
) -> str:
    """Get the weather for a given location."""
    return f"The weather in {location} is cloudy with a high of 15°C."

# When creating a ChatAgent directly
agent = ChatAgent(
    chat_client=OpenAIChatClient(),
    instructions="You are a helpful assistant",
    tools=[get_weather]
)

# When using factory helper methods
agent = OpenAIChatClient().create_agent(
    instructions="You are a helpful assistant",
    tools=[get_weather]
)
```

## Tools per run (dynamic tools)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-tools

```python
# Agent created without tools
agent = ChatAgent(
    chat_client=OpenAIChatClient(),
    instructions="You are a helpful assistant"
)

# Provide tools for specific runs
result1 = await agent.run(
    "What's the weather in Seattle?",
    tools=[get_weather]
)

# Use different tools for different runs
result2 = await agent.run(
    "What's the current time?",
    tools=[get_time]
)

# Provide multiple tools for a single run
result3 = await agent.run(
    "What's the weather and time in Chicago?",
    tools=[get_weather, get_time]
)
```

## OpenAI Responses agent with tools

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/openai-responses-agent

```python
from typing import Annotated
from pydantic import Field

# Add: from agent_framework.openai import OpenAIResponsesClient

def get_weather(
    location: Annotated[str, Field(description="The location to get weather for")]
) -> str:
    """Get the weather for a given location."""
    return f"The weather in {location} is sunny with 25°C."

async def tools_example():
    agent = OpenAIResponsesClient().create_agent(
        instructions="You are a helpful weather assistant.",
        tools=get_weather,
    )

    result = await agent.run("What's the weather like in Tokyo?")
    print(result.text)
```

## Azure OpenAI Responses agent with tools

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/azure-openai-responses-agent

```python
import asyncio
from typing import Annotated
from agent_framework.azure import AzureOpenAIResponsesClient
from azure.identity import AzureCliCredential
from pydantic import Field

def get_weather(
    location: Annotated[str, Field(description="The location to get the weather for.")],
) -> str:
    """Get the weather for a given location."""
    return f"The weather in {location} is sunny with a high of 25°C."

async def main():
    agent = AzureOpenAIResponsesClient(credential=AzureCliCredential()).create_agent(
        instructions="You are a helpful weather assistant.",
        tools=get_weather
    )

    result = await agent.run("What's the weather like in Seattle?")
    print(result.text)

asyncio.run(main())
```

## ChatAgent tools (Azure OpenAI Responses)

Source: https://context7.com/microsoft/agent-framework/llms.txt

```python
import asyncio
from datetime import datetime, timezone
from random import randint
from typing import Annotated
from agent_framework import ChatAgent
from agent_framework.azure import AzureOpenAIResponsesClient
from azure.identity import AzureCliCredential
from pydantic import Field

def get_weather(
    location: Annotated[str, Field(description="The location to get the weather for.")]
) -> str:
    """Get the weather for a given location."""
    conditions = ["sunny", "cloudy", "rainy", "stormy"]
    return f"The weather in {location} is {conditions[randint(0, 3)]} with a high of {randint(10, 30)}°C."

def get_time() -> str:
    """Get the current UTC time."""
    current_time = datetime.now(timezone.utc)
    return f"The current UTC time is {current_time.strftime('%Y-%m-%d %H:%M:%S')}."

async def main():
    agent = ChatAgent(
        chat_client=AzureOpenAIResponsesClient(credential=AzureCliCredential()),
        instructions="You are a helpful assistant that can provide weather and time information.",
        tools=[get_weather, get_time]
    )

    result1 = await agent.run("What's the weather like in New York?")
    print(f"Agent: {result1}")

    result2 = await agent.run("What's the weather in London and what's the current UTC time?")
    print(f"Agent: {result2}")

    agent_no_tools = ChatAgent(
        chat_client=AzureOpenAIResponsesClient(credential=AzureCliCredential()),
        instructions="You are a helpful assistant."
    )

    result3 = await agent_no_tools.run(
        "What's the weather like in Seattle?",
        tools=[get_weather]
    )
    print(f"Agent: {result3}")

asyncio.run(main())
```

## HostedCodeInterpreterTool (Azure AI Agent client)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types

```python
from agent_framework import ChatAgent, HostedCodeInterpreterTool
from agent_framework.azure import AzureAIAgentClient
from azure.identity.aio import DefaultAzureCredential

async with (
    DefaultAzureCredential() as credential,
    ChatAgent(
        chat_client=AzureAIAgentClient(async_credential=credential),
        instructions="You are a helpful assistant that can execute Python code.",
        tools=HostedCodeInterpreterTool()
    ) as agent
):
    response = await agent.run("Calculate the factorial of 100 using Python")
```
