# Agent RAG (Python)

## Table of contents

- Azure AI Search collection + agent
- Multiple search tools
- VectorStore integration note

## Azure AI Search collection + agent

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-rag

```python
collection = AzureAISearchCollection[str, SupportArticle](
    record_type=SupportArticle,
    embedding_generator=OpenAITextEmbedding()
)

async with collection:
    await collection.ensure_collection_exists()
    # Load your knowledge base articles into the collection
    # await collection.upsert(articles)

    # Create a search function from the collection
    search_function = collection.create_search_function(
        function_name="search_knowledge_base",
        description="Search the knowledge base for support articles and product information.",
        search_type="keyword_hybrid",
        parameters=[
            KernelParameterMetadata(
                name="query",
                description="The search query to find relevant information.",
                type="str",
                is_required=True,
                type_object=str,
            ),
            KernelParameterMetadata(
                name="top",
                description="Number of results to return.",
                type="int",
                default_value=3,
                type_object=int,
            ),
        ],
        string_mapper=lambda x: f"[{x.record.category}] {x.record.title}: {x.record.content}",
    )

    # Convert the search function to an Agent Framework tool
    search_tool = search_function.as_agent_framework_tool()

    # Create an agent with the search tool
    agent = OpenAIResponsesClient(model_id="gpt-4o").create_agent(
        instructions="You are a helpful support specialist. Use the search tool to find relevant information before answering questions. Always cite your sources.",
        tools=search_tool
    )

    response = await agent.run("How do I return a product?")
    print(response.text)
```

## Multiple search tools

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-rag

```python
product_search = product_collection.create_search_function(
    function_name="search_products",
    description="Search for product information and specifications.",
    search_type="semantic_hybrid",
    string_mapper=lambda x: f"{x.record.name}: {x.record.description}",
).as_agent_framework_tool()

policy_search = policy_collection.create_search_function(
    function_name="search_policies",
    description="Search for company policies and procedures.",
    search_type="keyword_hybrid",
    string_mapper=lambda x: f"Policy: {x.record.title}\n{x.record.content}",
).as_agent_framework_tool()

agent = chat_client.create_agent(
    instructions="You are a support agent. Use the appropriate search tool to find information before answering. Cite your sources.",
    tools=[product_search, policy_search]
)
```

## VectorStore integration note

Source: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-rag

Notes:
- Uses Semantic Kernel VectorStore collections converted via `.as_agent_framework_tool()`.
- Requires `semantic-kernel` version 1.38 or higher.
