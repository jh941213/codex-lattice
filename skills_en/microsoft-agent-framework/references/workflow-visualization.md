# Workflow Visualization (Python)

## Table of contents

- Generate Mermaid and Graphviz output
- Export diagrams

## Generate Mermaid and Graphviz output

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/visualization

```python
from agent_framework import WorkflowBuilder, WorkflowViz

workflow = (
    WorkflowBuilder()
    .set_start_executor(dispatcher)
    .add_fan_out_edges(dispatcher, [researcher, marketer, legal])
    .add_fan_in_edges([researcher, marketer, legal], aggregator)
    .build()
)

viz = WorkflowViz(workflow)

print(viz.to_mermaid())
print(viz.to_digraph())
```

## Export diagrams

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/visualization

```python
print(viz.export(format="svg"))
print(viz.export(format="png"))
print(viz.export(format="pdf"))
print(viz.export(format="dot"))
print(viz.export(format="svg", filename="my_workflow.svg"))
print(viz.save_svg("workflow.svg"))
print(viz.save_png("workflow.png"))
print(viz.save_pdf("workflow.pdf"))
```

Note: Image export requires GraphViz installed and the `graphviz` Python package.
