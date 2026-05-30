#!/usr/bin/env ruby
# Test SSE connection to Algolia MCP
# Run with: rails runner scripts/test_sse.rb

puts "🔍 Testing Algolia MCP with SSE\n\n"

mcp_client = AlgoliaMcpClient.new

puts "=" * 60
puts "Attempting SSE connection to Algolia MCP..."
puts "=" * 60

response = mcp_client.list_tools

puts "\n📊 Response:"
puts JSON.pretty_generate(response)

if response['error']
  puts "\n❌ Error: #{response['error']}"
  puts "Details: #{response['details']}" if response['details']
else
  tools = response.dig('result', 'tools') || []
  puts "\n✅ Success! Found #{tools.length} tools"
  tools.each do |tool|
    puts "  - #{tool['name']}: #{tool['description']}"
  end
end
