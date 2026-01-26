require 'net/http'
require 'json'

class AlgoliaSearchService
  OLLAMA_URL = 'http://localhost:11434'
  
  def initialize
    # Initialize Algolia MCP client
    @mcp_client = AlgoliaMcpClient.new
  end

  def ask(user_query, &block)
    Rails.logger.info("🎯 User Query: #{user_query}")
    
    # Step 1: Get available tools from Algolia MCP
    tools_response = @mcp_client.list_tools
    
    if tools_response['error']
      msg = "Sorry, I couldn't connect to the search service. #{tools_response['error']}"
      return block_given? ? (yield msg) : msg
    end

    available_tools = tools_response.dig('result', 'tools') || []
    Rails.logger.info("🔧 Available tools: #{available_tools.length} tools found")
    
    if available_tools.empty?
      Rails.logger.warn("⚠️ No tools available from Algolia MCP - using direct Ollama")
      return ask_ollama_direct(user_query, &block)
    end
    
    # Step 2: Format tools for Ollama
    ollama_tools = available_tools.map do |tool|
      {
        type: 'function',
        function: {
          name: tool['name'],
          description: tool['description'],
          parameters: tool['inputSchema']
        }
      }
    end
    
    Rails.logger.info("🔨 Formatted #{ollama_tools.length} tools for Ollama")
    Rails.logger.info("🔨 Tool names: #{ollama_tools.map { |t| t[:function][:name] }.join(', ')}")

    # Step 3: Send query to Ollama with available tools
    # CRITICAL: Add system prompt to encourage tool usage
    messages = [
      {
        role: 'system',
        content: 'You are a helpful assistant for finding vendor events. You have access to search tools. ALWAYS use the algolia_search_index_Event tool when users ask about finding events. Never respond without using the search tool first.'
      },
      {
        role: 'user',
        content: user_query
      }
    ]
    
    begin
      Rails.logger.info("📤 Sending to Ollama with #{ollama_tools.length} tools")
      
      response = call_ollama_chat(
        model: 'llama3.2',
        messages: messages,
        tools: ollama_tools
      )

      Rails.logger.info("📥 Ollama response keys: #{response.keys}")
      message = response['message']
      Rails.logger.info("📨 Message keys: #{message.keys if message}")
      Rails.logger.info("📨 Has tool_calls?: #{message&.key?('tool_calls')}")
      
      # Step 4: Check if Ollama wants to use a tool
      if message && message['tool_calls']
        Rails.logger.info("✅ Ollama IS calling #{message['tool_calls'].length} tool(s)!")
        
        message['tool_calls'].each do |tool_call|
          function_name = tool_call.dig('function', 'name')
          arguments = tool_call.dig('function', 'arguments')
          
          Rails.logger.info("📞 Calling tool: #{function_name}")
          
          # Step 5: Execute the tool via MCP
          tool_result = @mcp_client.call_tool(function_name, arguments)
          
          # Add tool result to conversation
          messages << message
          messages << {
            role: 'tool',
            content: tool_result.to_json
          }
        end

        # Step 6: Get final response from Ollama with tool results
        final_response = call_ollama_chat(
          model: 'llama3.2',
          messages: messages
        )

        content = final_response.dig('message', 'content')
        return block_given? ? (yield content) : content
      else
        # No tool calls, just return the response
        Rails.logger.warn("⚠️ Ollama did NOT call any tools - returning direct response")
        Rails.logger.warn("⚠️ This might mean the model doesn't support tool calling")
        content = message['content']
        return block_given? ? (yield content) : content
      end
    rescue StandardError => e
      Rails.logger.error("❌ Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      error_msg = "Sorry, I encountered an error: #{e.message}"
      return block_given? ? (yield error_msg) : error_msg
    end
  end

  private

  def ask_ollama_direct(user_query, &block)
    Rails.logger.info("💬 Asking Ollama directly (no tools)")
    
    response = call_ollama_chat(
      model: 'llama3.2',
      messages: [{ role: 'user', content: user_query }]
    )
    
    content = response.dig('message', 'content')
    return block_given? ? (yield content) : content
  end

  def call_ollama_chat(model:, messages:, tools: nil)
    uri = URI("#{OLLAMA_URL}/api/chat")
    
    payload = {
      model: model,
      messages: messages,
      stream: false
    }
    payload[:tools] = tools if tools
    
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      raise "Ollama API error: #{response.code} - #{response.body}"
    end
  end
end
