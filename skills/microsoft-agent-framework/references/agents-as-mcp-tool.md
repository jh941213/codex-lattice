# Agent as MCP Tool (Python)

## Table of contents

- Create agent with tools for MCP server

## Create agent with tools for MCP server

Source: https://learn.microsoft.com/en-us/agent-framework/tutorials/agents/agent-as-mcp-tool

```python
from typing import Annotated
from agent_framework.openai import OpenAIResponsesClient


def get_specials() -> Annotated[str, "Returns the specials from the menu."]:
    return """
        Special Soup: Clam Chowder
        Special Salad: Cobb Salad
        Special Drink: Chai Tea
        """


def get_item_price(
    menu_item: Annotated[str, "The name of the menu item."],
) -> Annotated[str, "Returns the price of the menu item."]:
    return "$9.99"

# Create an agent with tools
agent = OpenAIResponsesClient().create_agent(
    name="RestaurantAgent",
    description="Answer questions about the menu.",
    tools=[get_specials, get_item_price],
)
```
