require 'net/http'
require 'json'
require 'uri'

app_id = 'MHB695BBRR'
api_key = '5e35c8b0017e2cb6d22af3c79eee939e'
index_name = 'Event'

uri = URI("https://#{app_id}-dsn.algolia.net/1/indexes/#{index_name}/query")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.path)
request['X-Algolia-Application-Id'] = app_id
request['X-Algolia-API-Key'] = api_key
request['Content-Type'] = 'application/json'

# Test search for Texas
request.body = {
  query: 'texas',
  hitsPerPage: 5
}.to_json

puts "🔍 Testing Algolia search for 'texas'..."
response = http.request(request)

if response.is_a?(Net::HTTPSuccess)
  data = JSON.parse(response.body)
  puts "✅ Algolia Response:"
  puts "   Total hits: #{data['nbHits']}"
  puts "   Returned: #{data['hits'].length}"
  
  if data['hits'].any?
    puts "\n📋 First result:"
    first = data['hits'].first
    puts "   - Name: #{first['name']}"
    puts "   - City: #{first['city']}"
    puts "   - State: #{first['state']}"
    puts "   - Address: #{first['address']}"
    puts "   - ObjectID: #{first['objectID']}"
  else
    puts "\n⚠️  No results found!"
    puts "\n🔍 Index might be empty. Checking index settings..."
    
    # Get index settings
    settings_uri = URI("https://#{app_id}-dsn.algolia.net/1/indexes/#{index_name}/settings")
    settings_request = Net::HTTP::Get.new(settings_uri.path)
    settings_request['X-Algolia-Application-Id'] = app_id
    settings_request['X-Algolia-API-Key'] = api_key
    
    settings_response = http.request(settings_request)
    if settings_response.is_a?(Net::HTTPSuccess)
      settings = JSON.parse(settings_response.body)
      puts "   Searchable attributes: #{settings['searchableAttributes']}"
    end
  end
else
  puts "❌ Algolia Error: #{response.code} - #{response.body}"
end
