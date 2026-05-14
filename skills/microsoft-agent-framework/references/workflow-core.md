# Workflows Core Concepts (Python)

## Table of contents

- Built-in events
- Consume workflow events
- Custom events
- Executor (class-based)
- Executor (@executor decorator)
- Workflows (WorkflowBuilder)
- Direct edges
- Fan-out edges
- Fan-out edges with selection
- Switch-case edges
- Fan-in edges

## Built-in events

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/events

```python
# Workflow lifecycle events
WorkflowStartedEvent    # Workflow execution begins
WorkflowOutputEvent     # Workflow produces an output
WorkflowErrorEvent      # Workflow encounters an error
WorkflowWarningEvent    # Workflow encountered a warning

# Executor events
ExecutorInvokedEvent    # Executor starts processing
ExecutorCompletedEvent  # Executor finishes processing
ExecutorFailedEvent     # Executor encounters an error
AgentRunEvent           # An agent run produces output
AgentRunUpdateEvent     # An agent run produces a streaming update

# Superstep events
SuperStepStartedEvent   # Superstep begins
SuperStepCompletedEvent # Superstep completes

# Request events
RequestInfoEvent        # A request is issued
```

## Consume workflow events

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/events

```python
from agent_framework import (
    ExecutorCompleteEvent,
    ExecutorInvokeEvent,
    WorkflowOutputEvent,
    WorkflowErrorEvent,
)

async for event in workflow.run_stream(input_message):
    match event:
        case ExecutorInvokeEvent() as invoke:
            print(f"Starting {invoke.executor_id}")
        case ExecutorCompleteEvent() as complete:
            print(f"Completed {complete.executor_id}: {complete.data}")
        case WorkflowOutputEvent() as output:
            print(f"Workflow produced output: {output.data}")
            return
        case WorkflowErrorEvent() as error:
            print(f"Workflow error: {error.exception}")
            return
```

## Custom events

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/events

```python
from agent_framework import (
    handler,
    Executor,
    WorkflowContext,
    WorkflowEvent,
)

class CustomEvent(WorkflowEvent):
    def __init__(self, message: str):
        super().__init__(message)

class CustomExecutor(Executor):

    @handler
    async def handle(self, message: str, ctx: WorkflowContext[str]) -> None:
        await ctx.add_event(CustomEvent(f"Processing message: {message}"))
        # Executor logic...
```

## Executor (class-based)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/executors

```python
from agent_framework import (
    Executor,
    WorkflowContext,
    handler,
)

class UpperCase(Executor):

    @handler
    async def to_upper_case(self, text: str, ctx: WorkflowContext[str]) -> None:
        """Convert input to uppercase and forward it."""
        await ctx.send_message(text.upper())
```

## Executor (@executor decorator)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/executors

```python
from agent_framework import (
    WorkflowContext,
    executor,
)

@executor(id="upper_case_executor")
async def upper_case(text: str, ctx: WorkflowContext[str]) -> None:
    """Convert input to uppercase and forward it."""
    await ctx.send_message(text.upper())
```

## Workflows (WorkflowBuilder)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/workflows

```python
from agent_framework import WorkflowBuilder

processor = DataProcessor()
validator = Validator()
formatter = Formatter()

builder = WorkflowBuilder()
builder.set_start_executor(processor)
builder.add_edge(processor, validator)
builder.add_edge(validator, formatter)
workflow = builder.build()
```

## Direct edges

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/edges

```python
from agent_framework import WorkflowBuilder

builder = WorkflowBuilder()
builder.add_edge(source_executor, target_executor)
builder.set_start_executor(source_executor)
workflow = builder.build()
```

## Fan-out edges

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/edges

```python
from agent_framework import WorkflowBuilder

builder = WorkflowBuilder()
builder.set_start_executor(splitter_executor)
builder.add_fan_out_edges(splitter_executor, [worker1, worker2, worker3])
workflow = builder.build()
```

## Fan-out edges with selection

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/edges

```python
builder = WorkflowBuilder()
builder.set_start_executor(splitter_executor)
builder.add_fan_out_edges(
    splitter_executor,
    [worker1, worker2, worker3],
    selection_func=lambda message, target_ids: (
        [0] if message.priority == Priority.HIGH else
        [1, 2] if message.priority == Priority.NORMAL else
        list(range(target_count))
    )
)
workflow = builder.build()
```

## Switch-case edges

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/edges

```python
from agent_framework import (
    Case,
    Default,
    WorkflowBuilder,
)

builder = WorkflowBuilder()
builder.set_start_executor(router_executor)
builder.add_switch_case_edge_group(
    router_executor,
    [
        Case(condition=lambda message: message.priority < Priority.NORMAL, target=executor_a),
        Case(condition=lambda message: message.priority < Priority.HIGH, target=executor_b),
        Default(target=executor_c),
    ],
)
workflow = builder.build()
```

## Fan-in edges

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/core-concepts/edges

```python
builder.add_fan_in_edge([worker1, worker2, worker3], aggregator_executor)
```
