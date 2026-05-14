# Quickstart: Python

## Install (core + connectors)

Source: https://github.com/microsoft/agent-framework/blob/main/python/CODING_STANDARD.md

```bash
# Core only
pip install agent-framework-core

# Core with all connectors
pip install agent-framework-core[all]
# or (equivalently):
pip install agent-framework

# Specific connector
pip install agent-framework-azure-ai
```

## Install preview builds (optional)

Source: https://github.com/microsoft/agent-framework/blob/main/python/packages/core/README.md

```bash
pip install agent-framework-core --pre
# Optional: Azure AI integration
pip install agent-framework-azure-ai --pre
```

## Basic agent (OpenAI)

Source: https://github.com/microsoft/agent-framework/blob/main/python/README.md

```python
import asyncio
from agent_framework import ChatAgent
from agent_framework.openai import OpenAIChatClient

async def main():
    agent = ChatAgent(
        chat_client=OpenAIChatClient(),
        instructions="""
        1) A robot may not injure a human being...
        2) A robot must obey orders given it by human beings...
        3) A robot must protect its own existence...

        Give me the TLDR in exactly 5 words.
        """
    )

    result = await agent.run("Summarize the Three Laws of Robotics")
    print(result)

asyncio.run(main())
```

## Basic agent (Azure OpenAI Responses)

Source: https://context7.com/microsoft/agent-framework/llms.txt

```python
import asyncio
from agent_framework.azure import AzureOpenAIResponsesClient
from azure.identity import AzureCliCredential

async def main():
    # Uses AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_RESPONSES_DEPLOYMENT_NAME,
    # and AZURE_OPENAI_API_VERSION from the environment.
    agent = AzureOpenAIResponsesClient(
        credential=AzureCliCredential()
    ).create_agent(
        name="HaikuBot",
        instructions="You are an upbeat assistant that writes beautifully."
    )

    result = await agent.run("Write a haiku about Microsoft Agent Framework.")
    print(result)

    async for chunk in agent.run_stream("Write another haiku about AI agents."):
        if chunk.text:
            print(chunk.text, end="", flush=True)

asyncio.run(main())
```

## OpenAIChatClient (direct)

Source: https://github.com/microsoft/agent-framework/blob/main/python/packages/core/README.md

```python
import asyncio
from agent_framework.openai import OpenAIChatClient
from agent_framework import ChatMessage, Role

async def main():
    client = OpenAIChatClient()

    messages = [
        ChatMessage(role=Role.SYSTEM, text="You are a helpful assistant."),
        ChatMessage(role=Role.USER, text="Write a haiku about Agent Framework.")
    ]

    response = await client.get_response(messages)
    print(response.messages[0].text)

asyncio.run(main())
```
