# Algolia MCP Server Setup Guide

This guide explains how to configure and use the Algolia MCP (Model Context Protocol) server integration with Ollama for intelligent event search.

## Overview

The app uses Ollama (local LLM) combined with Algolia's MCP server to provide natural language event search:
- **User asks**: "Find me events in Texas this summer"
- **Ollama** interprets the query and calls the Algolia search tool
- **MCP Server** executes the search against your Algolia index
- **Ollama** formats the results as a friendly response with event links

## Prerequisites

1. **Ollama installed and running** locally on port 11434
2. **Algolia account** with an indexed "Event" collection
3. **MCP Server URL** from Algolia (see below)

## Getting a New MCP Server URL

If your MCP server URL has expired (returning 500 errors), you need to generate a new one:

1. Visit: https://mcp.us.algolia.com/
2. Follow the authentication process
3. Select your application and index
4. Copy the generated MCP server URL
5. Update your `.env` file:

```bash
ALGOLIA_MCP_URL=https://mcp.us.algolia.com/1/YOUR_NEW_TOKEN/mcp
```

## Configuration

### Environment Variables

Add these to your `.env` file:

```bash
# Algolia Configuration
ALGOLIA_APP_ID=your_app_id
ALGOLIA_API_KEY=your_search_api_key
ALGOLIA_WRITE_KEY=your_write_api_key
ALGOLIA_MCP_URL=https://mcp.us.algolia.com/1/YOUR_TOKEN/mcp

# Ollama Configuration
OLLAMA_API_URL=http://localhost:11434
OLLAMA_MODEL=mistral
```

### Ollama Model

The app uses `llama3.2` model with tool calling support. Make sure you have it installed:

```bash
ollama pull llama3.2
```

## How It Works

### 1. User Sends Query
```javascript
// Frontend: algolia_chat_controller.js
POST /chat/message
{ message: "Find events in Chicago" }
```

### 2. AlgoliaSearchService Orchestrates
```ruby
# app/services/algolia_search_service.rb
service = AlgoliaSearchService.new
response = service.ask(user_message)
```

### 3. MCP Client Gets Available Tools
```ruby
# app/services/algolia_mcp_client.rb
tools = @mcp_client.list_tools
# Returns: [{ name: "algolia_search_index_Event", ... }]
```

### 4. Ollama Decides to Call Tool
```ruby
# Ollama receives system prompt + tools + user query
# Responds with tool_calls: [{ function: "algolia_search_index_Event", arguments: {...} }]
```

### 5. MCP Executes Search
```ruby
result = @mcp_client.call_tool("algolia_search_index_Event", {
  query: "Chicago",
  filters: nil,
  ...
})
```

### 6. Ollama Formats Response
```ruby
# Ollama receives tool results and formats them:
# "Here are the events I found:
#  1. **Chicago Summer Market**
#     • 📍 123 Main St, Chicago, IL
#     • 📅 June 15, 2026
#     • 🔗 [View Event Details](https://govend.ing/events/123)"
```

## Troubleshooting

### MCP Server Returns 500 Error
**Symptoms**: Logs show "Failed to handle MCP request"

**Solutions**:
1. Check if your MCP URL token has expired
2. Generate a new URL from https://mcp.us.algolia.com/
3. Update `ALGOLIA_MCP_URL` in `.env`
4. Restart Rails server

### Ollama Not Calling Tools
**Symptoms**: Logs show "Ollama did NOT call any tools"

**Solutions**:
1. Verify you're using `llama3.2` model (not `mistral`)
2. Check Ollama is running: `curl http://localhost:11434/api/tags`
3. Test Ollama directly:
   ```bash
   curl http://localhost:11434/api/chat -d '{
     "model": "llama3.2",
     "messages": [{"role": "user", "content": "test"}],
     "tools": [{"type": "function", "function": {"name": "test"}}]
   }'
   ```

### No Search Results
**Symptoms**: MCP works but returns empty results

**Solutions**:
1. Check your Algolia index has data
2. Verify index name matches in MCP configuration
3. Test direct Algolia search:
   ```ruby
   Event.search("test query")
   ```

### Fallback Mode Active
**Symptoms**: Logs show "Using direct Algolia search (MCP unavailable)"

**Explanation**: This is the fallback when MCP fails. It searches your local database instead.

**To Fix**: Resolve the MCP connection issue (see above)

## Performance Notes

The system automatically:
- Falls back to database search if MCP fails
- Caches geocoding results
- Uses lazy loading for heavy gems
- Disables verbose query logs in development

## Testing the Integration

### 1. Start Ollama
```bash
ollama serve
```

### 2. Start Rails Server
```bash
rails server
```

### 3. Test in Browser
Open the chat widget and try:
- "Find events in Texas"
- "Show me spring markets in California"
- "I'm looking for vendor events in Chicago"

### 4. Check Logs
Monitor `log/development.log` for:
- `✅ MCP session initialized successfully`
- `📞 Calling tool: algolia_search_index_Event`
- `📦 Tool result: ...`

## Files

- `app/services/algolia_mcp_client.rb` - MCP client implementation
- `app/services/algolia_search_service.rb` - Main orchestration service
- `app/controllers/chat_controller.rb` - API endpoint
- `app/javascript/controllers/algolia_chat_controller.js` - Frontend
- `config/initializers/algoliasearch.rb` - Algolia configuration
- `mcp-config.json` - MCP server configuration (legacy, use .env instead)

## Further Reading

- [Algolia MCP Documentation](https://www.algolia.com/doc/guides/mcp/)
- [Ollama Tool Calling](https://github.com/ollama/ollama/blob/main/docs/api.md#tool-calling)
- [Model Context Protocol Spec](https://spec.modelcontextprotocol.io/)
