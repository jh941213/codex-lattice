# Observability (Python)

## Table of contents

- Azure Monitor + Agent Framework instrumentation
- Observability for custom agents (OpenTelemetry ID)
- setup_observability (OTLP)
- Azure AI client configure_azure_monitor

## Azure Monitor + Agent Framework instrumentation

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/observability

```python
from azure.monitor.opentelemetry import configure_azure_monitor
from agent_framework.observability import create_resource, enable_instrumentation

# Configure Azure Monitor first
configure_azure_monitor(
    connection_string="InstrumentationKey=...",
    resource=create_resource(),
    enable_live_metrics=True,
)

# Then activate Agent Framework telemetry code paths
enable_instrumentation(enable_sensitive_data=False)
```

## Observability for custom agents (OpenTelemetry ID)

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/enable-observability

```python
from azure.monitor.opentelemetry import configure_azure_monitor
from agent_framework import ChatAgent
from agent_framework.observability import create_resource, enable_instrumentation
from agent_framework.openai import OpenAIChatClient

configure_azure_monitor(
    connection_string="InstrumentationKey=...",
    resource=create_resource(),
    enable_live_metrics=True,
)
# Optional if ENABLE_INSTRUMENTATION is already set in env vars
enable_instrumentation()

agent = ChatAgent(
    chat_client=OpenAIChatClient(),
    name="My Agent",
    instructions="You are a helpful assistant.",
    id="<OpenTelemetry agent ID>"
)
```

## setup_observability (OTLP)

Source: https://learn.microsoft.com/en-us/agent-framework/migration-guide/from-autogen/index

```python
from agent_framework import ChatAgent
from agent_framework.observability import setup_observability
from agent_framework.openai import OpenAIChatClient

# Zero-code setup via env vars (example):
# ENABLE_OTEL=true
# OTLP_ENDPOINT=http://localhost:4317

# Or manual setup
setup_observability(
    otlp_endpoint="http://localhost:4317"
)

client = OpenAIChatClient(model_id="gpt-5")

async def observability_example():
    agent = ChatAgent(name="assistant", chat_client=client)
    result = await agent.run("Hello")
```

## Azure AI client configure_azure_monitor

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/observability

```python
from agent_framework.azure import AzureAIClient
from azure.ai.projects.aio import AIProjectClient
from azure.identity.aio import AzureCliCredential

async def main():
    async with (
        AzureCliCredential() as credential,
        AIProjectClient(endpoint="https://<your-project>.foundry.azure.com", credential=credential) as project_client,
        AzureAIClient(project_client=project_client) as client,
    ):
        await client.configure_azure_monitor(enable_live_metrics=True)
```
