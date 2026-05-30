#!/usr/bin/env ruby
# Test script for Algolia MCP integration
# Run with: rails runner scripts/test_mcp.rb

puts "🧪 Testing Algolia MCP Integration\n\n"

# Test 1: MCP Client Connection
puts "=" * 50
puts "Test 1: Connecting to Algolia MCP Server"
puts "=" * 50

mcp_client = AlgoliaMcpClient.new
tools_response = mcp_client.list_tools

if tools_response['error']
  puts "❌ Failed to connect: #{tools_response['error']}"
  exit 1
else
  puts "✅ Connected successfully!"
  tools = tools_response.dig('result', 'tools') || []
  puts "\n📋 Available tools (#{tools.length}):"
  tools.each do |tool|
    puts "  - #{tool['name']}: #{tool['description']}"
  end
end

# Test 2: Full Integration
puts "\n"
puts "=" * 50
puts "Test 2: Full Ollama + MCP Integration"
puts "=" * 50

service = AlgoliaSearchService.new
test_query = "Find events in Texas"

puts "\n💬 Query: #{test_query}"
puts "\n🤖 Response:"
puts "-" * 50

response = service.ask(test_query)
puts response

puts "\n" + "=" * 50
puts "✅ All tests completed!"
