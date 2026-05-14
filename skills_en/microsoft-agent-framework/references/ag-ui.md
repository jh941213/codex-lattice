# AG-UI Integration (Python)

## Table of contents

- Overview and mapping
- AG-UI client with approvals
- State management with confirmation

## Overview and mapping

Source: https://learn.microsoft.com/en-us/agent-framework/integrations/ag-ui

Key points:
- AG-UI exposes agents over HTTP/SSE for streaming.
- ChatAgent maps to an AG-UI agent endpoint.
- run() maps to HTTP POST, run_stream() maps to SSE updates.
- Tool approvals map to AG-UI human-in-the-loop messages.
- Threads map to AG-UI threadId for conversation continuity.

## AG-UI client with approvals

Source: https://learn.microsoft.com/en-us/agent-framework/integrations/ag-ui/human-in-the-loop

```python
"""AG-UI client with human-in-the-loop support."""

import asyncio
import os

from agent_framework import ChatAgent, ToolCallContent
from agent_framework_ag_ui import AGUIChatClient


def display_approval_request(update) -> None:
    """Display approval request details to the user."""
    print("\n" + "=" * 60)
    print("APPROVAL REQUIRED")
    print("=" * 60)

    for i, content in enumerate(update.contents, 1):
        if isinstance(content, ToolCallContent):
            print(f"\nAction {i}:")
            print(f"  Tool: {content.name}")
            print("  Arguments:")
            for key, value in (content.arguments or {}).items():
                print(f"    {key}: {value}")

    print("\n" + "=" * 60)


async def main():
    server_url = os.environ.get("AGUI_SERVER_URL", "http://127.0.0.1:8888/")
    print(f"Connecting to AG-UI server at: {server_url}\n")

    chat_client = AGUIChatClient(server_url=server_url)

    agent = ChatAgent(
        name="ClientAgent",
        chat_client=chat_client,
        instructions="You are a helpful assistant.",
    )

    thread = agent.get_new_thread()

    while True:
        message = input("\nUser (:q or quit to exit): ")
        if not message.strip():
            continue
        if message.lower() in (":q", "quit"):
            break

        print("\nAssistant: ", end="", flush=True)
        pending_approval_update = None

        async for update in agent.run_stream(message, thread=thread):
            if update.additional_properties and update.additional_properties.get("requires_approval"):
                pending_approval_update = update
                display_approval_request(update)
                break

        if pending_approval_update:
            approval_id = pending_approval_update.additional_properties.get("approvalId")
            user_choice = input("\nApprove this action? (yes/no): ").strip().lower()
            approved = user_choice in ("yes", "y")

            async for event in chat_client.send_approval_response(approval_id, approved):
                event_type = event.get("type", "")
                if event_type == "TEXT_MESSAGE_CONTENT":
                    print(event.get("delta", ""), end="", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
```

Note: This snippet is an example client loop; adapt handling to your UI.

## State management with confirmation

Source: https://learn.microsoft.com/en-us/agent-framework/integrations/ag-ui/state-management

```python
from agent_framework_ag_ui import AgentFrameworkAgent
from agent_framework_ag_ui import RecipeConfirmationStrategy

recipe_agent = AgentFrameworkAgent(
    agent=agent,
    state_schema={"recipe": {"type": "object", "description": "The current recipe"}},
    predict_state_config={"recipe": {"tool": "update_recipe", "tool_argument": "recipe"}},
    require_confirmation=True,
    confirmation_strategy=RecipeConfirmationStrategy(),
)
```
