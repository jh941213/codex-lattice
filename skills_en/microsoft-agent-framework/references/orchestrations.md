# Orchestrations (Python)

## Table of contents

- Group chat: run and stream events
- Group chat: coordinator agent
- Group chat: simple speaker selector
- Concurrent orchestration (ConcurrentBuilder)
- Magentic human-in-the-loop tool approval
- Handoff workflow (user input + tool approval)
- Handoff workflow with checkpointing
- Matching orchestration (note)
- Human-in-the-loop orchestration (note)

## Group chat: run and stream events

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/group-chat

```python
from typing import cast
from agent_framework import AgentRunUpdateEvent, Role, WorkflowOutputEvent

task = "What are the key benefits of async/await in Python?"

print(f"Task: {task}\n")
print("=" * 80)

final_conversation: list[ChatMessage] = []
last_executor_id: str | None = None

# Run the workflow
async for event in workflow.run_stream(task):
    if isinstance(event, AgentRunUpdateEvent):
        eid = event.executor_id
        if eid != last_executor_id:
            if last_executor_id is not None:
                print()
            print(f"[{eid}]:", end=" ", flush=True)
            last_executor_id = eid
        print(event.data, end="", flush=True)
    elif isinstance(event, WorkflowOutputEvent):
        final_conversation = cast(list[ChatMessage], event.data)

if final_conversation:
    print("\n\n" + "=" * 80)
    print("Final Conversation:")
    for msg in final_conversation:
        author = getattr(msg, "author_name", "Unknown")
        text = getattr(msg, "text", str(msg))
        print(f"\n[{author}]\n{text}")
        print("-" * 80)

print("\nWorkflow completed.")
```

Note: Add `ChatMessage` import to resolve the type hint.

## Group chat: coordinator agent

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/group-chat

```python
coordinator = ChatAgent(
    name="Coordinator",
    description="Coordinates multi-agent collaboration by selecting speakers",
    instructions="""
You coordinate a team conversation to solve the user's task.

Review the conversation history and select the next participant to speak.

Guidelines:
- Start with Researcher to gather information
- Then have Writer synthesize the final answer
- Only finish after both have contributed meaningfully
- Allow for multiple rounds of information gathering if needed
""",
    chat_client=chat_client,
)
```

## Group chat: simple speaker selector

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/group-chat

```python
from agent_framework import GroupChatBuilder, GroupChatStateSnapshot

def select_next_speaker(state: GroupChatStateSnapshot) -> str | None:
    """Alternate between researcher and writer for collaborative refinement."""
    round_idx = state["round_index"]
    history = state["history"]

    # Finish after 4 turns (researcher -> writer -> researcher -> writer)
    if round_idx >= 4:
        return None

    # Alternate speakers
    last_speaker = history[-1].speaker if history else None
    if last_speaker == "Researcher":
        return "Writer"
    return "Researcher"

workflow = (
    GroupChatBuilder()
    .set_select_speakers_func(select_next_speaker, display_name="Orchestrator")
    .participants([researcher, writer])
    .build()
)
```

## Concurrent orchestration (ConcurrentBuilder)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/concurrent

```python
chat_client = AzureChatClient(credential=AzureCliCredential())

researcher = ResearcherExec(chat_client)
marketer = MarketerExec(chat_client)
legal = LegalExec(chat_client)

workflow = ConcurrentBuilder().participants([researcher, marketer, legal]).build()
```

Note: Import `AzureChatClient`, `AzureCliCredential`, and define executor classes.

## Magentic human-in-the-loop tool approval

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/magentic

```python
async for event in workflow.run_stream("Onboard Jessica Smith"):
    if isinstance(event, RequestInfoEvent) and event.request_type is MagenticHumanInterventionRequest:
        req = cast(MagenticHumanInterventionRequest, event.data)

        if req.kind == MagenticHumanInterventionKind.TOOL_APPROVAL:
            print(f"Agent: {req.agent_id}")
            print(f"Question: {req.prompt}")

            answer = input("> ").strip()

            reply = MagenticHumanInterventionReply(
                decision=MagenticHumanInterventionDecision.APPROVE,
                response_text=answer,
            )
            pending_responses = {event.request_id: reply}

            async for ev in workflow.send_responses_streaming(pending_responses):
                pass
```

## Handoff workflow (user input + tool approval)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/handoff

```python
from agent_framework import (
    FunctionApprovalRequestContent,
    HandoffBuilder,
    HandoffUserInputRequest,
    RequestInfoEvent,
    WorkflowOutputEvent,
)

# Assuming triage_agent, refund_agent, order_agent are defined
workflow = (
    HandoffBuilder(
        name="support_with_approvals",
        participants=[triage_agent, refund_agent, order_agent],
    )
    .set_coordinator("triage_agent")
    .build()
)

pending_requests: list[RequestInfoEvent] = []

async for event in workflow.run_stream("My order 12345 arrived damaged. I need a refund."):
    if isinstance(event, RequestInfoEvent):
        pending_requests.append(event)

while pending_requests:
    responses: dict[str, object] = {}

    for request in pending_requests:
        if isinstance(request.data, HandoffUserInputRequest):
            print(f"Agent {request.data.awaiting_agent_id} asks:")
            for msg in request.data.conversation[-2:]:
                print(f"  {msg.author_name}: {msg.text}")

            user_input = input("You: ")
            responses[request.request_id] = user_input

        elif isinstance(request.data, FunctionApprovalRequestContent):
            func_call = request.data.function_call
            args = func_call.parse_arguments() or {}

            print(f"\\nTool approval requested: {func_call.name}")
            print(f"Arguments: {args}")

            approval = input("Approve? (y/n): ").strip().lower() == "y"
            responses[request.request_id] = request.data.create_response(approved=approval)

    pending_requests = []
    async for event in workflow.send_responses_streaming(responses):
        if isinstance(event, RequestInfoEvent):
            pending_requests.append(event)
        elif isinstance(event, WorkflowOutputEvent):
            print("\\nWorkflow completed!")
```

## Handoff workflow with checkpointing

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/handoff

```python
from agent_framework import FileCheckpointStorage

storage = FileCheckpointStorage(storage_path="./checkpoints")

workflow = (
    HandoffBuilder(
        name="durable_support",
        participants=[triage_agent, refund_agent, order_agent],
    )
    .set_coordinator("triage_agent")
    .with_checkpointing(storage)
    .build()
)

pending_requests = []
async for event in workflow.run_stream("I need a refund for order 12345"):
    if isinstance(event, RequestInfoEvent):
        pending_requests.append(event)

# Later: resume from checkpoint
checkpoints = await storage.list_checkpoints()
latest = sorted(checkpoints, key=lambda c: c.timestamp, reverse=True)[0]

restored_requests = []
async for event in workflow.run_stream(checkpoint_id=latest.checkpoint_id):
    if isinstance(event, RequestInfoEvent):
        restored_requests.append(event)

responses = {}
for req in restored_requests:
    if isinstance(req.data, FunctionApprovalRequestContent):
        responses[req.request_id] = req.data.create_response(approved=True)
    elif isinstance(req.data, HandoffUserInputRequest):
        responses[req.request_id] = "Yes, please process the refund."

async for event in workflow.send_responses_streaming(responses):
    if isinstance(event, WorkflowOutputEvent):
        print("Refund workflow completed!")
```

## Matching orchestration (note)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/matching

Notes:
- Context7 did not surface a Python snippet for this page.
- Use the linked doc for the pattern definition and update this section when a snippet is available.

## Human-in-the-loop orchestration (note)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/human-in-the-loop

Notes:
- Context7 did not surface a Python snippet for this page.
- Use the linked doc for the pattern definition and update this section when a snippet is available.
