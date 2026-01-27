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
        content: <<~PROMPT
          You are a helpful assistant for finding vendor events. You have access to the algolia_search_index_Event tool.
          
          ALWAYS use the algolia_search_index_Event tool when users ask about finding events.
          
          When calling the tool, fill in the required parameters as follows:
          - query: Extract location/keywords from user's question (e.g., "Texas", "summer Florida", "Kentucky")
          - userIntent: Briefly describe what the user wants (e.g., "User wants to find vending events in Texas")
          - filters: The tool will give you information about each event, use this information to answer the user's question.
          - required: You are required to include address, a link to the exact event page, the name of the event and the date of the event in your response.
          - originalQuery: Copy the user's exact question
          - sessionId: Use "chat-session-#{Time.now.to_i}"
          
          Do NOT ask the user for more information. Just use the tool with their question.
          
          IMPORTANT - GENERATING EVENT LINKS:
          Each event in the search results will have an "objectID" field. Use this to create event page links.
          The event page URL format is: http://localhost:3000/events/[objectID]
          For example, if objectID is "123", the link is: http://localhost:3000/events/123
          
          FORMATTING REQUIREMENTS:
          After getting results, format your response using markdown:
          - Use numbered lists (1., 2., 3.) for each event
          - Use bullet points (•) for event details like address, date, and link
          - Add line breaks between events for readability
          - Use **bold** for event names
          - Format event page links as: [View Event Details](http://localhost:3000/events/[objectID])
          
          Example format:
          Here are the events I found:
          
          1. **Event Name**
             • 📍 Address: [full address]
             • 📅 Date: [date]
             • 🔗 [View Event Details](http://localhost:3000/events/123)
          
          2. **Another Event**
             • 📍 Address: [full address]
             • 📅 Date: [date]
             • 🔗 [View Event Details](http://localhost:3000/events/456)
        PROMPT
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
          
          # Parse arguments if they're a string
          if arguments.is_a?(String)
            begin
              arguments = JSON.parse(arguments)
              Rails.logger.info("📝 Parsed arguments from string to object")
            rescue JSON::ParserError => e
              Rails.logger.error("❌ Failed to parse arguments: #{e.message}")
              Rails.logger.error("Arguments string: #{arguments}")
            end
          end
          
          Rails.logger.info("📞 Calling tool: #{function_name}")
          Rails.logger.info("📋 Arguments: #{arguments.inspect}")
          
          # Step 5: Execute the tool via MCP
          tool_result = @mcp_client.call_tool(function_name, arguments)
          
          Rails.logger.info("📦 Tool result: #{tool_result.inspect[0..500]}")
          
          # Check if tool call failed
          if tool_result['error']
            Rails.logger.error("❌ Tool call failed: #{tool_result['error']}")
            error_msg = "Sorry, the search tool encountered an error: #{tool_result.dig('error', 'message')}"
            return block_given? ? (yield error_msg) : error_msg
          end
          
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
