#!/usr/bin/env ruby
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'net-http'
  gem 'json'
  gem 'uri'
end

# Test Ollama connection
def test_ollama
  puts "\n=== Testing Ollama Connection ==="
  uri = URI('http://localhost:11434/api/tags')
  response = Net::HTTP.get_response(uri)
  
  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    puts "✅ Ollama is running"
    puts "📦 Available models: #{data['models'].map { |m| m['name'] }.join(', ')}"
    true
  else
    puts "❌ Ollama connection failed: #{response.code}"
    false
  end
rescue StandardError => e
  puts "❌ Ollama error: #{e.message}"
  false
end

# Test Algolia MCP connection
def test_algolia_mcp
  puts "\n=== Testing Algolia MCP Connection ==="
  
  mcp_url = "https://mcp.us.algolia.com/1/8_VwMrM0dXIKCrJOTE1KNkoztkg1M001Nk01NDBMMUkzszBOSTRNMk9MSrN2LUvNK7E2NDezNDU1N7O0AAA/mcp"
  uri = URI(mcp_url)
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.read_timeout = 30
  
  # Initialize session
  init_payload = {
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: {
        name: "goVend",
        version: "1.0.0"
      }
    }
  }
  
  request = Net::HTTP::Post.new(uri.path)
  request['Content-Type'] = 'application/json'
  request['Accept'] = 'application/json, text/event-stream'
  request['Cache-Control'] = 'no-cache'
  request.body = init_payload.to_json
  
  puts "📤 Sending initialize request..."
  response = http.request(request)
  
  puts "📥 Response code: #{response.code}"
  puts "📥 Response body (first 500 chars): #{response.body[0..500]}"
  
  if response.is_a?(Net::HTTPSuccess)
    puts "✅ MCP connection successful"
    
    # Try to list tools
    puts "\n=== Listing Available Tools ==="
    tools_payload = {
      jsonrpc: "2.0",
      id: 2,
      method: "tools/list"
    }
    
    request2 = Net::HTTP::Post.new(uri.path)
    request2['Content-Type'] = 'application/json'
    request2['Accept'] = 'application/json, text/event-stream'
    request2['Cache-Control'] = 'no-cache'
    request2.body = tools_payload.to_json
    
    tools_response = http.request(request2)
    puts "📥 Tools response code: #{tools_response.code}"
    puts "📥 Tools response body: #{tools_response.body[0..1000]}"
    
    # Parse SSE
    lines = tools_response.body.split("\n")
    data_lines = lines.select { |line| line.start_with?('data:') }
    
    if data_lines.any?
      last_data = data_lines.last.sub('data:', '').strip
      tools_data = JSON.parse(last_data)
      
      if tools_data['result'] && tools_data['result']['tools']
        tools = tools_data['result']['tools']
        puts "\n✅ Found #{tools.length} tools:"
        tools.each do |tool|
          puts "  - #{tool['name']}: #{tool['description']}"
        end
        return true
      end
    end
    
    puts "⚠️ No tools found in response"
    false
  else
    puts "❌ MCP connection failed: #{response.code} - #{response.body}"
    false
  end
rescue StandardError => e
  puts "❌ MCP error: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  false
end

# Test tool calling with Ollama
def test_ollama_tool_calling
  puts "\n=== Testing Ollama Tool Calling ==="
  
  uri = URI('http://localhost:11434/api/chat')
  
  tools = [
    {
      type: 'function',
      function: {
        name: 'test_function',
        description: 'A test function',
        parameters: {
          type: 'object',
          properties: {
            query: { type: 'string', description: 'Test query' }
          },
          required: ['query']
        }
      }
    }
  ]
  
  payload = {
    model: 'llama3.2:latest',
    messages: [
      { role: 'system', content: 'You have access to test_function. Use it when asked about testing.' },
      { role: 'user', content: 'Can you call the test function with query "hello"?' }
    ],
    tools: tools,
    stream: false
  }
  
  request = Net::HTTP::Post.new(uri.path)
  request['Content-Type'] = 'application/json'
  request.body = payload.to_json
  
  response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
  
  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    message = data['message']
    
    if message && message['tool_calls']
      puts "✅ Ollama supports tool calling!"
      puts "📞 Tool calls: #{message['tool_calls'].inspect}"
      true
    else
      puts "⚠️ Ollama did not make tool calls"
      puts "📝 Response: #{message['content']}"
      false
    end
  else
    puts "❌ Ollama request failed: #{response.code}"
    false
  end
rescue StandardError => e
  puts "❌ Tool calling test error: #{e.message}"
  false
end

# Run all tests
puts "🔍 Starting diagnostics...\n"

ollama_ok = test_ollama
mcp_ok = test_algolia_mcp
tools_ok = test_ollama_tool_calling

puts "\n" + "="*50
puts "📊 Summary:"
puts "  Ollama: #{ollama_ok ? '✅' : '❌'}"
puts "  Algolia MCP: #{mcp_ok ? '✅' : '❌'}"
puts "  Tool Calling: #{tools_ok ? '✅' : '❌'}"
puts "="*50

if !ollama_ok
  puts "\n⚠️ Fix: Make sure Ollama is running (ollama serve)"
end

if !mcp_ok
  puts "\n⚠️ Fix: Check your Algolia MCP URL - it may be expired. Get a new one from https://mcp.us.algolia.com/"
end

if !tools_ok
  puts "\n⚠️ Fix: gemma3:4b may not support tool calling. Consider using llama3.2 or qwen2.5 models"
end
