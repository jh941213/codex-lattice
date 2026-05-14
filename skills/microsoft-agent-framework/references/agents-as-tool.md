# Agents as Tools (Python)

## Table of contents

- Expose an agent as a function tool

## Expose an agent as a function tool

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/agent-as-function-tool_pivots=programming-language-csharp

```python
main_agent = AzureOpenAIChatClient(credential=AzureCliCredential()).create_agent(
    instructions="You are a helpful assistant who responds in French.",
    tools=weather_agent.as_tool()
)
```

Note: Define `weather_agent` first, then pass `weather_agent.as_tool()` into the main agent.
