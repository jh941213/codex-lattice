# DevUI (Python)

## Table of contents

- Clone and run DevUI samples
- Directory discovery (CLI)
- Directory structure
- Responses API via OpenAI SDK
- DevUI entity management API
- Security and deployment (best practices)

## Clone and run DevUI samples

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/samples

```bash
git clone https://github.com/microsoft/agent-framework.git
cd agent-framework/python/samples/getting_started/devui
```

## Directory discovery (CLI)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/directory-discovery

```bash
# Discover all entities in ./entities directory
devui ./entities

# With custom port
devui ./entities --port 9000

# With auto-reload for development
devui ./entities --reload
```

## Directory structure

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/directory-discovery

```text
entities/
    weather_agent/
        __init__.py      # Must export: agent = ChatAgent(...)
        agent.py         # Agent implementation (optional)
        .env             # Optional: API keys, config vars
    my_workflow/
        __init__.py      # Must export: workflow = WorkflowBuilder()...
        workflow.py      # Workflow implementation (optional)
        .env             # Optional: environment variables
    .env                 # Optional: shared environment variables
```

## Responses API via OpenAI SDK

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/api-reference

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="not-needed"  # API key not required for local DevUI
)

response = client.responses.create(
    metadata={"entity_id": "weather_agent"},  # Your agent/workflow name
    input="What's the weather in Seattle?"
)

# Extract text from response
print(response.output[0].content[0].text)
```

## DevUI entity management API

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/api-reference

```text
GET  /v1/entities
GET  /v1/entities/{entity_id}/info
POST /v1/entities/{entity_id}/reload
```

## Security and deployment (best practices)

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/devui/security

Notes:
- Store secrets in `.env` files; do not commit secrets to source control.
- Keep DevUI bound to localhost in development.
- Use a reverse proxy (nginx, Caddy) with HTTPS and auth for external access.
- Only load trusted agent/workflow code; review tools with side effects.
