# Agents and Images (Python)

## Table of contents

- Create image analysis agent
- Send local image file
- Send image URL
- Run agent with image

## Create image analysis agent

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/images

```python
import asyncio
from agent_framework.azure import AzureOpenAIChatClient
from azure.identity import AzureCliCredential

agent = AzureOpenAIChatClient(credential=AzureCliCredential()).create_agent(
    name="VisionAgent",
    instructions="You are a helpful agent that can analyze images"
)
```

## Send local image file

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/images

```python
from agent_framework import ChatMessage, TextContent, DataContent, Role

# Load image from local file
with open("path/to/your/image.jpg", "rb") as f:
    image_bytes = f.read()

message = ChatMessage(
    role=Role.USER,
    contents=[
        TextContent(text="What do you see in this image?"),
        DataContent(
            data=image_bytes,
            media_type="image/jpeg"
        )
    ]
)
```

## Send image URL

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/images

```python
from agent_framework import ChatMessage, TextContent, UriContent, Role

message = ChatMessage(
    role=Role.USER,
    contents=[
        TextContent(text="What do you see in this image?"),
        UriContent(
            uri="https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg",
            media_type="image/jpeg"
        )
    ]
)
```

## Run agent with image

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/images

```python
async def main():
    result = await agent.run(message)
    print(result.text)

asyncio.run(main())
```
