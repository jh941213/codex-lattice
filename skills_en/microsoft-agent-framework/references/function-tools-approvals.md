# Function Tools Approvals (Python)

## Table of contents

- Mark tools for approval
- Handle approvals loop
- Use approvals in a request

## Mark tools for approval

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/function-tools-approvals

```python
from agent_framework import ai_function
from typing import Annotated

@ai_function(approval_mode="always_require")
def get_weather_detail(location: Annotated[str, "The city and state, e.g. San Francisco, CA"]) -> str:
    """Get detailed weather information for a given location."""
    return f"The weather in {location} is cloudy with a high of 15C, humidity 88%."
```

## Handle approvals loop

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/function-tools-approvals

```python
from agent_framework import ChatMessage, Role

async def handle_approvals(query: str, agent) -> str:
    """Handle function call approvals in a loop."""
    current_input = query

    while True:
        result = await agent.run(current_input)

        if not result.user_input_requests:
            return result.text

        new_inputs = [query]

        for user_input_needed in result.user_input_requests:
            print(f"Approval needed for: {user_input_needed.function_call.name}")
            print(f"Arguments: {user_input_needed.function_call.arguments}")

            new_inputs.append(ChatMessage(role=Role.ASSISTANT, contents=[user_input_needed]))

            # Replace with real user input
            user_approval = True

            new_inputs.append(
                ChatMessage(role=Role.USER, contents=[user_input_needed.create_response(user_approval)])
            )

        current_input = new_inputs
```

## Use approvals in a request

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/function-tools-approvals

```python
result_text = await handle_approvals("Get detailed weather for Seattle and Portland", agent)
print(result_text)
```
