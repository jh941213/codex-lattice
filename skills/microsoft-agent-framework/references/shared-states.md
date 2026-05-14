# Workflow Shared States (Python)

## Table of contents

- Write shared state
- Read shared state

## Write shared state

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/shared-states

```python
from agent_framework import (
    Executor,
    WorkflowContext,
    handler,
)
import uuid

class FileReadExecutor(Executor):

    @handler
    async def handle(self, file_path: str, ctx: WorkflowContext[str]):
        # Read file content
        with open(file_path, "r") as file:
            file_content = file.read()
        # Store file content in shared state
        file_id = str(uuid.uuid4())
        await ctx.set_shared_state(file_id, file_content)

        await ctx.send_message(file_id)
```

## Read shared state

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/shared-states

```python
from agent_framework import (
    Executor,
    WorkflowContext,
    handler,
)

class WordCountingExecutor(Executor):

    @handler
    async def handle(self, file_id: str, ctx: WorkflowContext[int]):
        file_content = await ctx.get_shared_state(file_id)
        if file_content is None:
            raise ValueError("File content state not found")

        await ctx.send_message(len(file_content.split()))
```
