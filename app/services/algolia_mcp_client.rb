require 'net/http'
require 'json'
require 'uri'

class AlgoliaMcpClient
  ALGOLIA_MCP_URL = "https://mcp.us.algolia.com/1/8_VwMrM0dXIKCrJOTE1KNkoztkg1M001Nk01NDBMMUkzszBOSTRNMk9MSrN2LUvNK7E2NDezNDU1szQ2BgA/mcp"
  
  def initialize
    @uri = URI(ALGOLIA_MCP_URL)
    @request_id = 0
    @initialized = false
  end

  # Initialize MCP session (required before other operations)
  def initialize_session
    return if @initialized
    
    response = send_sse_request({
      jsonrpc: "2.0",
      id: next_id,
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: {
          name: "goVend",
          version: "1.0.0"
        }
      }
    })
    
    if response['result']
      @initialized = true
      Rails.logger.info("✅ MCP session initialized successfully")
    else
      Rails.logger.error("❌ MCP initialization failed: #{response.inspect}")
    end
    
    response
  end

  # List available tools from Algolia MCP server
  def list_tools
    # Initialize session first if not already done
    initialize_session unless @initialized
    
    response = send_sse_request({
      jsonrpc: "2.0",
      id: next_id,
      method: "tools/list"
    })
    
    Rails.logger.info("🔍 Full MCP Response: #{response.inspect}")
    response
  end

  # Call a specific tool
  def call_tool(tool_name, arguments)
    send_sse_request({
      jsonrpc: "2.0",
      id: next_id,
      method: "tools/call",
      params: {
        name: tool_name,
        arguments: arguments
      }
    })
  end

  private

  def next_id
    @request_id += 1
  end

  def send_sse_request(payload)
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    
    # SSE requires GET with query parameters or special headers
    request = Net::HTTP::Post.new(@uri.path)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json, text/event-stream'  # Both required!
    request['Cache-Control'] = 'no-cache'
    request.body = payload.to_json

    Rails.logger.info("🔵 MCP SSE Request: #{payload.to_json}")
    
    response = http.request(request)
    
    Rails.logger.info("🟢 MCP Response Code: #{response.code}")
    Rails.logger.info("🟢 MCP Response Headers: #{response.to_hash.inspect}")
    Rails.logger.info("🟢 MCP Response Body: #{response.body[0..500]}")
    
    if response.is_a?(Net::HTTPSuccess)
      # Parse SSE format
      parse_sse_response(response.body)
    else
      Rails.logger.error("❌ MCP Error: #{response.code} - #{response.body}")
      { error: "MCP request failed: #{response.code}", details: response.body }
    end
  rescue StandardError => e
    Rails.logger.error("❌ MCP Exception: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    { error: e.message }
  end

  def parse_sse_response(body)
    # SSE format: "data: {...}\n\n"
    lines = body.split("\n")
    data_lines = lines.select { |line| line.start_with?('data:') }
    
    if data_lines.empty?
      Rails.logger.warn("⚠️ No data lines in SSE response")
      return { result: { tools: [] } }
    end
    
    # Get the last data line (most recent event)
    last_data = data_lines.last.sub('data:', '').strip
    
    begin
      JSON.parse(last_data)
    rescue JSON::ParserError => e
      Rails.logger.error("❌ Failed to parse SSE data: #{e.message}")
      { result: { tools: [] } }
    end
  end
end
