#!/usr/bin/env ruby
# Quick script to test MCP connection and provide troubleshooting info

require 'net/http'
require 'json'
require 'uri'

puts "🔍 MCP Server Connection Tester"
puts "=" * 50

# Load environment - look in project root, not script directory
project_root = File.expand_path('..', __dir__)
env_path = File.join(project_root, '.env')

puts "\n📂 Looking for .env at: #{env_path}"
puts "📂 Current directory: #{Dir.pwd}"
puts "📂 Script location: #{__dir__}"

if File.exist?(env_path)
  puts "✅ Found .env file"
  puts "📄 File size: #{File.size(env_path)} bytes"
  
  # Read the entire file content first
  content = File.read(env_path)
  
  # Split by lines, handling different line ending formats
  lines = content.split(/\r?\n/)
  
  puts "📄 Total lines: #{lines.length}"
  
  lines.each_with_index do |line, index|
    # Remove any carriage returns
    line = line.gsub(/\r/, '')
    
    # Skip empty lines and comments
    next if line.strip.empty? || line.strip.start_with?('#')
    
    # Split only on first =
    if line.include?('=')
      parts = line.split('=', 2)
      key = parts[0]&.strip
      value = parts[1]&.strip
      
      if key && value && !value.empty?
        ENV[key] = value
        if key.include?('ALGOLIA') || key.include?('OLLAMA')
          # Show partial value for security
          display_value = value.length > 50 ? "#{value[0..50]}..." : value
          puts "   ✓ Loaded: #{key} = #{display_value}"
        end
      end
    end
  end
  
  puts "\n🔍 Environment variables set:"
  puts "   ALGOLIA_MCP_URL present: #{ENV['ALGOLIA_MCP_URL'] ? 'YES' : 'NO'}"
  if ENV['ALGOLIA_MCP_URL']
    puts "   Value length: #{ENV['ALGOLIA_MCP_URL'].length} characters"
    puts "   First 60 chars: #{ENV['ALGOLIA_MCP_URL'][0..60]}..."
  end
else
  puts "❌ .env file not found at: #{env_path}"
  puts "\n📝 Make sure you're running this from the project root:"
  puts "   cd /mnt/c/Users/Anna/Desktop/Codestuff/go-vend-event"
  puts "   ruby scripts/test_mcp_connection.rb"
  exit 1
end

# Get MCP URL
mcp_url = ENV['ALGOLIA_MCP_URL']
if mcp_url.nil? || mcp_url.empty?
  puts "❌ ALGOLIA_MCP_URL not found in .env file"
  puts "\n📝 To fix this:"
  puts "1. Visit: https://mcp.us.algolia.com/"
  puts "2. Generate a new MCP URL"
  puts "3. Add it to .env file: ALGOLIA_MCP_URL=https://..."
  exit 1
end

puts "✅ Found MCP URL in environment"
puts "   URL: #{mcp_url[0..60]}..."

# Test connection
puts "\n🔌 Testing connection..."

uri = URI(mcp_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 10
http.open_timeout = 10

# Test 1: Initialize session
puts "\n1️⃣ Testing MCP initialization..."
request = Net::HTTP::Post.new(uri.path)
request['Content-Type'] = 'application/json'
request['Accept'] = 'text/event-stream'
request['Cache-Control'] = 'no-cache'
request['Connection'] = 'keep-alive'

payload = {
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

request.body = payload.to_json

begin
  response = http.request(request)
  
  puts "   Response Code: #{response.code}"
  puts "   Content-Type: #{response['Content-Type']}"
  
  if response.code.to_i == 200
    puts "   ✅ Initialize: SUCCESS"
    
    # Parse response
    body = response.body
    if body.include?('data:')
      # SSE format
      data_line = body.split("\n").find { |l| l.start_with?('data:') }
      if data_line
        json_data = data_line.sub('data:', '').strip
        result = JSON.parse(json_data)
        if result['error']
          puts "   ⚠️ Server returned error: #{result['error']['message']}"
        else
          puts "   ✅ Session initialized successfully"
        end
      end
    else
      # JSON format
      result = JSON.parse(body)
      if result['error']
        puts "   ⚠️ Server returned error: #{result['error']['message']}"
      else
        puts "   ✅ Session initialized successfully"
      end
    end
  elsif response.code.to_i == 500
    puts "   ❌ Initialize: FAILED (500 Internal Server Error)"
    puts "\n   This usually means:"
    puts "   - The MCP URL token has expired"
    puts "   - The server is temporarily unavailable"
    puts "\n   📝 To fix this:"
    puts "   1. Visit: https://mcp.us.algolia.com/"
    puts "   2. Generate a new MCP URL"
    puts "   3. Update ALGOLIA_MCP_URL in .env file"
    
    body = JSON.parse(response.body) rescue {}
    if body['error']
      puts "\n   Server error: #{body['error']['message']}"
    end
  else
    puts "   ❌ Initialize: FAILED (#{response.code})"
    puts "   Body: #{response.body[0..200]}"
  end
  
rescue StandardError => e
  puts "   ❌ Connection error: #{e.message}"
  puts "\n   This could mean:"
  puts "   - No internet connection"
  puts "   - Firewall blocking the connection"
  puts "   - MCP server is down"
end

# Test 2: Check Ollama
puts "\n2️⃣ Testing Ollama connection..."
ollama_url = ENV['OLLAMA_API_URL'] || 'http://localhost:11434'

begin
  ollama_uri = URI("#{ollama_url}/api/tags")
  ollama_http = Net::HTTP.new(ollama_uri.host, ollama_uri.port)
  ollama_request = Net::HTTP::Get.new(ollama_uri.path)
  ollama_response = ollama_http.request(ollama_request)
  
  if ollama_response.code.to_i == 200
    models = JSON.parse(ollama_response.body)['models'] || []
    puts "   ✅ Ollama is running"
    puts "   📦 Installed models:"
    
    has_llama32 = false
    models.each do |model|
      name = model['name']
      puts "      - #{name}"
      has_llama32 = true if name.include?('llama3.2')
    end
    
    if !has_llama32
      puts "\n   ⚠️ llama3.2 model not found"
      puts "   📝 Install it with: ollama pull llama3.2"
    end
  else
    puts "   ❌ Ollama is not responding"
  end
rescue StandardError => e
  puts "   ❌ Cannot connect to Ollama: #{e.message}"
  puts "   📝 Start Ollama with: ollama serve"
end

# Summary
puts "\n" + "=" * 50
puts "📊 Summary"
puts "=" * 50
puts "\nConfiguration:"
puts "  • MCP URL: #{mcp_url ? '✅ Set' : '❌ Missing'}"
puts "  • Ollama URL: #{ENV['OLLAMA_API_URL'] || 'http://localhost:11434'}"
puts "  • Algolia App ID: #{ENV['ALGOLIA_APP_ID'] || '❌ Missing'}"
puts "  • Algolia API Key: #{ENV['ALGOLIA_API_KEY'] ? '✅ Set' : '❌ Missing'}"

puts "\n📚 Next Steps:"
puts "  1. Fix any ❌ issues above"
puts "  2. Start Rails server: rails server"
puts "  3. Test chat at: http://localhost:3000"
puts "  4. Check logs: tail -f log/development.log"
