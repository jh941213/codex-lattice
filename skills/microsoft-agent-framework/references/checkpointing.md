# Workflow Checkpointing and Resuming (Python)

## Table of contents

- Build with checkpointing
- Stream resume from checkpoint
- Non-streaming resume
- Resume with pending requests
- Unified resume API (run_stream)

## Build with checkpointing

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/checkpointing-and-resuming

```python
import asyncio
from pathlib import Path

from agent_framework import (
    FileCheckpointStorage,
    WorkflowBuilder,
    WorkflowOutputEvent,
    get_checkpoint_summary
)

async def main():
    # Setup checkpoint storage
    checkpoint_dir = Path("./checkpoints")
    checkpoint_dir.mkdir(exist_ok=True)
    storage = FileCheckpointStorage(checkpoint_dir)

    # Build workflow with checkpointing
    workflow = (
        WorkflowBuilder()
        .add_edge(executor1, executor2)
        .set_start_executor(executor1)
        .with_checkpointing(storage)
        .build()
    )

    # Initial run
    print("Running workflow...")
    async for event in workflow.run_stream("input data"):
        print(f"Event: {event}")

    # List and inspect checkpoints
    checkpoints = await storage.list_checkpoints()
    for cp in sorted(checkpoints, key=lambda c: c.timestamp):
        summary = get_checkpoint_summary(cp)
        print(f"Checkpoint: {summary.checkpoint_id[:8]}... iter={summary.iteration_count}")

    # Resume from a checkpoint
    if checkpoints:
        latest = max(checkpoints, key=lambda cp: cp.timestamp)
        print(f"Resuming from: {latest.checkpoint_id}")

        async for event in workflow.run_stream(latest.checkpoint_id):
            print(f"Resumed: {event}")

if __name__ == "__main__":
    asyncio.run(main())
```

## Stream resume from checkpoint

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/checkpointing-and-resuming

```python
# Resume from a specific checkpoint
async for event in workflow.run_stream(
    checkpoint_id="checkpoint-id",
    checkpoint_storage=checkpoint_storage
):
    print(f"Resumed Event: {event}")

    if isinstance(event, WorkflowOutputEvent):
        print(f"Final Result: {event.data}")
        break
```

## Non-streaming resume

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/checkpointing-and-resuming

```python
# Resume and wait for completion
result = await workflow.run(
    checkpoint_id="checkpoint-id",
    checkpoint_storage=checkpoint_storage
)

# Access final outputs
outputs = result.get_outputs()
print(f"Final outputs: {outputs}")
```

## Resume with pending requests

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/checkpointing-and-resuming

```python
request_info_events = []
# Resume from checkpoint - pending requests will be re-emitted
async for event in workflow.run_stream(
    checkpoint_id="checkpoint-id",
    checkpoint_storage=checkpoint_storage
):
    if isinstance(event, RequestInfoEvent):
        # Capture re-emitted pending requests
        print(f"Pending request re-emitted: {event.request_id}")
        request_info_events.append(event)

# Handle the request and provide response
responses = {}
for event in request_info_events:
    response = handle_request(event.data)  # Your logic here
    responses[event.request_id] = response

# Send response back to workflow
async for event in workflow.send_responses_streaming(responses):
    if isinstance(event, WorkflowOutputEvent):
        print(f"Workflow completed: {event.data}")
```

## Unified resume API (run_stream)

Source: https://learn.microsoft.com/en-us/agent-framework/support/upgrade/requests-and-responses-upgrade-guide-python

```python
# NEW: Unified method with checkpoint_id parameter
async for event in workflow.run_stream(
    checkpoint_id="checkpoint-id",
    checkpoint_storage=checkpoint_storage  # Optional if configured at build time
):
    print(f"Event: {event}")
```
