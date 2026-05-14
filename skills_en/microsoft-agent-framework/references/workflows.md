# Workflows (Python)

## Table of contents

- WorkflowBuilder with agents (AzureChatClient)
- Workflow as agent (as_agent)
- Sequential workflow agent (streaming)
- Simple typed data flow graph (WorkflowBuilder)

## WorkflowBuilder with agents (AzureChatClient)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/using-agents

```python
from agent_framework import WorkflowBuilder
from agent_framework.azure import AzureChatClient
from azure.identity import AzureCliCredential

# Create the agents first
chat_client = AzureChatClient(credential=AzureCliCredential())
writer_agent: ChatAgent = chat_client.create_agent(
    instructions=(
        "You are an excellent content writer. You create new content and edit contents based on the feedback."
    ),
    name="writer_agent",
)
reviewer_agent = chat_client.create_agent(
    instructions=(
        "You are an excellent content reviewer."
        "Provide actionable feedback to the writer about the provided content."
        "Provide the feedback in the most concise manner possible."
    ),
    name="reviewer_agent",
)

# Build a workflow with the agents
builder = WorkflowBuilder()
builder.set_start_executor(writer_agent)
builder.add_edge(writer_agent, reviewer_agent)
workflow = builder.build()
```

Note: Add `from agent_framework import ChatAgent` if you want the type hint to resolve.

## Workflow as agent (as_agent)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/as-agents

```python
from agent_framework import WorkflowBuilder, ChatAgent
from agent_framework.azure import AzureOpenAIChatClient
from azure.identity import AzureCliCredential

# Create your chat client and agents
chat_client = AzureOpenAIChatClient(credential=AzureCliCredential())

researcher = ChatAgent(
    name="Researcher",
    instructions="Research and gather information on the given topic.",
    chat_client=chat_client,
)

writer = ChatAgent(
    name="Writer", 
    instructions="Write clear, engaging content based on research.",
    chat_client=chat_client,
)

# Build your workflow
workflow = (
    WorkflowBuilder()
    .set_start_executor(researcher)
    .add_edge(researcher, writer)
    .build()
)

# Convert the workflow to an agent
workflow_agent = workflow.as_agent(name="Content Pipeline Agent")
```

## Sequential workflow agent (streaming)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/as-agents

```python
import asyncio
from agent_framework import (
    ChatAgent,
    ChatMessage,
    Role,
)
from agent_framework.azure import AzureOpenAIChatClient
from agent_framework._workflows import SequentialBuilder
from azure.identity import AzureCliCredential


async def main():
    # Set up the chat client
    chat_client = AzureOpenAIChatClient(credential=AzureCliCredential())

    # Create specialized agents
    researcher = ChatAgent(
        name="Researcher",
        instructions="Research the given topic and provide key facts.",
        chat_client=chat_client,
    )

    writer = ChatAgent(
        name="Writer",
        instructions="Write engaging content based on the research provided.",
        chat_client=chat_client,
    )

    reviewer = ChatAgent(
        name="Reviewer",
        instructions="Review the content and provide a final polished version.",
        chat_client=chat_client,
    )

    # Build a sequential workflow
    workflow = (
        SequentialBuilder()
        .add_agents([researcher, writer, reviewer])
        .build()
    )

    # Convert to a workflow agent
    workflow_agent = workflow.as_agent(name="Content Creation Pipeline")

    # Create a thread and run the workflow
    thread = workflow_agent.get_new_thread()
    messages = [ChatMessage(role=Role.USER, content="Write about quantum computing")]

    print("Starting workflow...")
    print("=" * 60)

    current_author = None
    async for update in workflow_agent.run_stream(messages, thread=thread):
        # Show when different agents are responding
        if update.author_name and update.author_name != current_author:
            if current_author:
                print("\n" + "-" * 40)
            print(f"\n[{update.author_name}]:")
            current_author = update.author_name

        if update.text:
            print(update.text, end="", flush=True)

    print("\n" + "=" * 60)
    print("Workflow completed!")


if __name__ == "__main__":
    asyncio.run(main())
```

## Simple typed data flow graph (WorkflowBuilder)

Source: https://learn.microsoft.com/en-us/agent-framework/migration-guide/from-autogen/index

```python
from agent_framework import WorkflowBuilder

# Build typed data flow graph
workflow = (
    WorkflowBuilder()
    .add_edge(agent1_executor, agent2_executor)
    .set_start_executor(agent1_executor)
    .build()
)

# Example usage (would be in async context)
# result = await workflow.run("Initial input")
```
