# Workflow Tutorials (Python)

## Table of contents

- Agents in workflows (simple sequential)
- Run workflow and stream events
- Simple concurrent workflow (fan-out/fan-in)
- Branching logic (switch-case vs multi-selection)
- Fan-out + join (ANY vs ALL) + routing (advanced)
- WorkflowBuilder with factories
- SequentialBuilder participants

## Agents in workflows (simple sequential)

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/agents-in-workflows

```python
# Build the workflow with agents as executors
workflow = WorkflowBuilder().set_start_executor(writer).add_edge(writer, reviewer).build()
```

Note: The snippet assumes `writer` and `reviewer` are already created agents.

## Run workflow and stream events

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/simple-sequential-workflow

```python
async def main():
    # Run the workflow and stream events
    async for event in workflow.run_stream("hello world"):
        print(f"Event: {event}")
        if isinstance(event, WorkflowOutputEvent):
            print(f"Workflow completed with result: {event.data}")

if __name__ == "__main__":
    asyncio.run(main())
```

Note: Add `from agent_framework import WorkflowOutputEvent` if needed.

## Simple concurrent workflow (fan-out/fan-in)

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/simple-concurrent-workflow

```python
async def main() -> None:
    # 1) Create the executors
    dispatcher = Dispatcher(id="dispatcher")
    average = Average(id="average")
    summation = Sum(id="summation")
    aggregator = Aggregator(id="aggregator")

    # 2) Build a simple fan out and fan in workflow
    workflow = (
        WorkflowBuilder()
        .set_start_executor(dispatcher)
        .add_fan_out_edges(dispatcher, [average, summation])
        .add_fan_in_edges([average, summation], aggregator)
        .build()
    )
```

Note: Define the `Dispatcher`, `Average`, `Sum`, and `Aggregator` executors and import `WorkflowBuilder`.

## Branching logic (switch-case vs multi-selection)

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/workflow-with-branching-logic

```python
# One input -> exactly one output
.add_switch_case_edge_group(
    source,
    [
        Case(condition=lambda x: x.result == "A", target=handler_a),
        Case(condition=lambda x: x.result == "B", target=handler_b),
        Default(target=handler_c),
    ],
)
```

```python
# One input -> one or more outputs (dynamic fan-out)
.add_multi_selection_edge_group(
    source,
    [handler_a, handler_b, handler_c, handler_d],
    selection_func=intelligent_router,  # Returns list of target IDs
)
```

Note: This snippet assumes `Case`, `Default`, `source`, and handlers are defined.

## Fan-out + join (ANY vs ALL) + routing (advanced)

Source: https://learn.microsoft.com/en-us/agent-framework/migration-guide/from-autogen/index

```python
# Agent Framework Workflow — A -> (B, C) -> aggregator (ALL vs ANY)
from agent_framework import WorkflowBuilder, executor, WorkflowContext
from typing_extensions import Never

@executor(id="A")
async def start(task: str, ctx: WorkflowContext[str]) -> None:
    await ctx.send_message(f"B:{task}", target_id="B")
    await ctx.send_message(f"C:{task}", target_id="C")

@executor(id="B")
async def branch_b(text: str, ctx: WorkflowContext[str]) -> None:
    await ctx.send_message(f"B_done:{text}")

@executor(id="C")
async def branch_c(text: str, ctx: WorkflowContext[str]) -> None:
    await ctx.send_message(f"C_done:{text}")

@executor(id="join_any")
async def join_any(msg: str, ctx: WorkflowContext[Never, str]) -> None:
    await ctx.yield_output(f"First: {msg}")  # ANY join (first arrival)

@executor(id="join_all")
async def join_all(msg: str, ctx: WorkflowContext[str, str]) -> None:
    state = await ctx.get_executor_state() or {"items": []}
    state["items"].append(msg)
    await ctx.set_executor_state(state)
    if len(state["items"]) >= 2:
        await ctx.yield_output(" | ".join(state["items"]))  # ALL join

wf_any = (
    WorkflowBuilder()
    .add_edge(start, branch_b).add_edge(start, branch_c)
    .add_edge(branch_b, join_any).add_edge(branch_c, join_any)
    .set_start_executor(start)
    .build()
)

wf_all = (
    WorkflowBuilder()
    .add_edge(start, branch_b).add_edge(start, branch_c)
    .add_edge(branch_b, join_all).add_edge(branch_c, join_all)
    .set_start_executor(start)
    .build()
)
```

Note: This pattern shows routing via `target_id`, plus join strategies.

## WorkflowBuilder with factories

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/workflow-builder-with-factories

```python
# Build the workflow using the builder
workflow_a = workflow_builder.build()
await workflow_a.run("hello world")
await workflow_a.run("hello world")

# Build another workflow using the builder
```

Note: Rebuild to start with a fresh workflow instance when needed.

## SequentialBuilder participants

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/sequential

```python
from agent_framework import SequentialBuilder

# 2) Build sequential workflow: writer -> reviewer
workflow = SequentialBuilder().participants([writer, reviewer]).build()
```
