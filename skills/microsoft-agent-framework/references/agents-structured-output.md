# Agents Structured Output (Python)

## Table of contents

- Structured output with Pydantic (OpenAI Responses)
- Structured output via response_format
- Structured output from streaming

## Structured output with Pydantic (OpenAI Responses)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/openai-responses-agent

```python
from pydantic import BaseModel
from agent_framework import AgentRunResponse
# Add: from agent_framework.openai import OpenAIResponsesClient

class CityInfo(BaseModel):
    """A structured output for city information."""
    city: str
    description: str

async def structured_output_example():
    agent = OpenAIResponsesClient().create_agent(
        name="CityExpert",
        instructions="You describe cities in a structured format.",
    )

    # Non-streaming structured output
    result = await agent.run("Tell me about Paris, France", response_format=CityInfo)

    if result.value:
        city_data = result.value
        print(f"City: {city_data.city}")
        print(f"Description: {city_data.description}")

    # Streaming structured output
    structured_result = await AgentRunResponse.from_agent_response_generator(
        agent.run_stream("Tell me about Tokyo, Japan", response_format=CityInfo),
        output_format_type=CityInfo,
    )

    if structured_result.value:
        tokyo_data = structured_result.value
        print(f"City: {tokyo_data.city}")
        print(f"Description: {tokyo_data.description}")
```

## Structured output via response_format

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/structured-output

```python
response = await agent.run(
    "Please provide information about John Smith, who is a 35-year-old software engineer.",
    response_format=PersonInfo
)
```

## Structured output from streaming

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/structured-output

```python
from agent_framework import AgentRunResponse

final_response = await AgentRunResponse.from_agent_response_generator(
    agent.run_stream(query, response_format=PersonInfo),
    output_format_type=PersonInfo,
)

if final_response.value:
    person_info = final_response.value
    print(f"Name: {person_info.name}, Age: {person_info.age}, Occupation: {person_info.occupation}")
```
