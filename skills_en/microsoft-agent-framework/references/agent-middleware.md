# Agent Middleware (Python)

## Table of contents

- Function-based agent middleware (logging)
- Class-based agent middleware
- Agent-level vs run-level middleware
- Add middleware to agent (tutorial)

## Function-based agent middleware (logging)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-middleware

```python
async def logging_agent_middleware(
    context: AgentRunContext,
    next: Callable[[AgentRunContext], Awaitable[None]],
) -> None:
    """Agent middleware that logs execution timing."""
    # Pre-processing: Log before agent execution
    print("[Agent] Starting execution")

    # Continue to next middleware or agent execution
    await next(context)

    # Post-processing: Log after agent execution
    print("[Agent] Execution completed")
```

Note: Add `AgentRunContext`, `Callable`, and `Awaitable` imports as needed.

## Class-based agent middleware

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-middleware

```python
from agent_framework import AgentMiddleware, AgentRunContext

class LoggingAgentMiddleware(AgentMiddleware):
    """Agent middleware that logs execution."""

    async def process(
        self,
        context: AgentRunContext,
        next: Callable[[AgentRunContext], Awaitable[None]],
    ) -> None:
        # Pre-processing: Log before agent execution
        print("[Agent Class] Starting execution")

        # Continue to next middleware or agent execution
        await next(context)

        # Post-processing: Log after agent execution
        print("[Agent Class] Execution completed")
```

## Agent-level vs run-level middleware

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-middleware

```python
from agent_framework.azure import AzureAIAgentClient
from azure.identity.aio import AzureCliCredential
# Assume SecurityAgentMiddleware, TimingFunctionMiddleware, and logging_chat_middleware are defined elsewhere

credential = AzureCliCredential()

def get_weather():
    return ""

# Agent-level middleware: applied to all runs
async with AzureAIAgentClient(async_credential=credential).create_agent(
    name="WeatherAgent",
    instructions="You are a helpful weather assistant.",
    tools=get_weather,
    middleware=[
        SecurityAgentMiddleware(),
        TimingFunctionMiddleware(),
    ],
) as agent:

    # Agent-level middleware only
    result1 = await agent.run("What's the weather in Seattle?")

    # Agent-level + run-level middleware
    result2 = await agent.run(
        "What's the weather in Portland?",
        middleware=[
            logging_chat_middleware,
        ]
    )

    # Agent-level middleware only
    result3 = await agent.run("What's the weather in Vancouver?")
```

## Add middleware to agent (tutorial)

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/middleware

```python
async def main():
    credential = AzureCliCredential()

    async with AzureAIAgentClient(async_credential=credential).create_agent(
        name="GreetingAgent",
        instructions="You are a friendly greeting assistant.",
        middleware=logging_agent_middleware,
    ) as agent:
        result = await agent.run("Hello!")
        print(result.text)
```
