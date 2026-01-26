#!/usr/bin/env ruby
# Debug script to inspect Algolia MCP response
# Run with: rails runner scripts/debug_mcp.rb

puts "🔍 Debugging Algolia MCP Connection\n\n"

mcp_client = AlgoliaMcpClient.new

puts "=" * 60
puts "Testing different MCP methods:"
puts "=" * 60

# Test 1: Initialize
puts "\n1️⃣ Testing initialize method..."
init_response = mcp_client.send(:send_request, {
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
})
puts "Response: #{JSON.pretty_generate(init_response)}"

# Test 2: List Tools
puts "\n2️⃣ Testing tools/list method..."
tools_response = mcp_client.list_tools
puts "Response: #{JSON.pretty_generate(tools_response)}"

# Test 3: List Resources (if available)
puts "\n3️⃣ Testing resources/list method..."
resources_response = mcp_client.send(:send_request, {
  jsonrpc: "2.0",
  id: 3,
  method: "resources/list"
})
puts "Response: #{JSON.pretty_generate(resources_response)}"

puts "\n" + "=" * 60
puts "Debug complete!"
puts "=" * 60
