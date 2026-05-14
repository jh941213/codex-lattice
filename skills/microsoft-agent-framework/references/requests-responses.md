# Workflow Requests and Responses (Python)

## Table of contents

- Executor request/response handlers
- Handle RequestInfoEvent and send responses
- Define request/response models

## Executor request/response handlers

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/requests-and-responses

```python
from agent_framework import (
    Executor,
    WorkflowContext,
    handler,
    response_handler,
)

class SomeExecutor(Executor):

    @handler
    async def handle_data(
        self,
        data: OtherDataType,
        context: WorkflowContext,
    ):
        # Process the message...
        ...
        # Send a request using the API
        await context.request_info(
            request_data=CustomRequestType(...),
            response_type=CustomResponseType
        )

    @response_handler
    async def handle_response(
        self,
        original_request: CustomRequestType,
        response: CustomResponseType,
        context: WorkflowContext,
    ):
        # Process the response...
        ...
```

## Handle RequestInfoEvent and send responses

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/requests-and-responses

```python
from agent_framework import RequestInfoEvent

while True:
    request_info_events: list[RequestInfoEvent] = []
    pending_responses: dict[str, CustomResponseType] = {}

    stream = workflow.run_stream(input) if not pending_responses else workflow.send_responses_streaming(pending_responses)

    async for event in stream:
        if isinstance(event, RequestInfoEvent):
            # Handle `RequestInfoEvent` from the workflow
            request_info_events.append(event)

    if not request_info_events:
        break

    for request_info_event in request_info_events:
        # Build and stage responses
        response = CustomResponseType(...)
        pending_responses[request_info_event.request_id] = response
```

## Define request/response models

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/requests-and-responses

```python
from dataclasses import dataclass
from pydantic import BaseModel

from agent_framework import (
    AgentExecutorRequest,
    AgentExecutorResponse,
)

@dataclass
class HumanFeedbackRequest(AgentExecutorRequest):
    """Request message for human feedback in the guessing game."""
    prompt: str = ""
    guess: int | None = None

class GuessOutput(BaseModel):
    """Structured output from the AI agent with response_format enforcement."""
    guess: int
```
