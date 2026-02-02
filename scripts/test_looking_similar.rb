require 'net/http'
require 'json'
require 'uri'

puts "🔍 Testing Algolia Looking Similar Model..."
puts "="*60

app_id = ENV['ALGOLIA_APP_ID'] || 'MHB695BBRR'
api_key = ENV['ALGOLIA_API_KEY'] || '5e35c8b0017e2cb6d22af3c79eee939e'
index_name = 'Event'

# Pick a random event to test with
event = Event.first
if event.nil?
  puts "❌ No events found in database!"
  exit 1
end

puts "Testing with Event: #{event.name} (ID: #{event.id})"
puts ""

# Test Looking Similar
uri = URI("https://#{app_id}-dsn.algolia.net/1/indexes/*/recommendations")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.read_timeout = 10

request = Net::HTTP::Post.new(uri.path)
request['X-Algolia-Application-Id'] = app_id
request['X-Algolia-API-Key'] = api_key
request['Content-Type'] = 'application/json'

request.body = {
  requests: [
    {
      indexName: index_name,
      model: 'looking-similar',
      objectID: event.id.to_s,
      maxRecommendations: 5
    }
  ]
}.to_json

puts "📤 Sending request to Algolia Recommend API..."
response = http.request(request)

puts "📥 Response code: #{response.code}"
puts ""

if response.is_a?(Net::HTTPSuccess)
  data = JSON.parse(response.body)
  results = data.dig('results', 0, 'hits') || []
  
  if results.any?
    puts "✅ SUCCESS! Looking Similar is working!"
    puts ""
    puts "Found #{results.length} similar events:"
    results.each_with_index do |hit, i|
      puts "  #{i+1}. #{hit['name']} (ID: #{hit['objectID']})"
      puts "     📍 #{hit['city']}, #{hit['state']}"
    end
  else
    puts "⚠️  Model returned 0 results."
    puts ""
    puts "This could mean:"
    puts "  1. The model needs to be enabled in Algolia Dashboard"
    puts "  2. Not enough data for recommendations yet"
    puts "  3. The event has no similar events"
  end
else
  data = JSON.parse(response.body) rescue {}
  error_message = data.dig('message') || response.body
  
  puts "❌ Error from Algolia:"
  puts error_message
  puts ""
  
  if error_message.include?("not enabled") || error_message.include?("Model not found")
    puts "📋 TO FIX:"
    puts "  1. Go to: https://www.algolia.com/apps/#{app_id}/recommend/overview"
    puts "  2. Click 'Create Model'"
    puts "  3. Select 'Looking Similar'"
    puts "  4. Choose index: 'Event'"
    puts "  5. Click 'Create'"
    puts ""
    puts "  The model will be ready in a few minutes!"
  end
end

puts ""
puts "="*60
