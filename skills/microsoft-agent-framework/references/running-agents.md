# Running Agents (Python)

## Table of contents

- Non-streaming run
- Streaming run
- Agent threads (multi-turn)
- Multi-turn conversation example
- Multiple independent threads

## Non-streaming run

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/running-agents

```python
result = await agent.run("What is the weather like in Amsterdam?")
print(result.text)
```

## Streaming run

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/running-agents

```python
async for update in agent.run_stream("What is the weather like in Amsterdam?"):
    print(f"Update text: {update.text}")
    print(f"Content count: {len(update.contents)}")

    for content in update.contents:
        if hasattr(content, 'text'):
            print(f"Content: {content.text}")
```

## Agent threads (multi-turn)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/multi-turn-conversation

```python
# Create a new thread.
thread = agent.get_new_thread()
# Run the agent with the thread.
response = await agent.run("Hello, how are you?", thread=thread)

# Run an agent with a temporary thread.
response = await agent.run("Hello, how are you?")
```

## Multi-turn conversation example

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/multi-turn-conversation

```python
thread = agent.get_new_thread()

async def main():
    result1 = await agent.run("Tell me a joke about a pirate.", thread=thread)
    print(result1.text)

    result2 = await agent.run(
        "Now add some emojis to the joke and tell it in the voice of a pirate's parrot.",
        thread=thread
    )
    print(result2.text)

asyncio.run(main())
```

## Multiple independent threads

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/multi-turn-conversation

```python
async def main():
    thread1 = agent.get_new_thread()
    thread2 = agent.get_new_thread()

    result1 = await agent.run("Tell me a joke about a pirate.", thread=thread1)
    print(result1.text)

    result2 = await agent.run("Tell me a joke about a robot.", thread=thread2)
    print(result2.text)

    result3 = await agent.run(
        "Now add some emojis to the joke and tell it in the voice of a pirate's parrot.",
        thread=thread1
    )
    print(result3.text)

    result4 = await agent.run(
        "Now add some emojis to the joke and tell it in the voice of a robot.",
        thread=thread2
    )
    print(result4.text)

asyncio.run(main())
```
