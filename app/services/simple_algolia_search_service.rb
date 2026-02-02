require 'net/http'
require 'json'

class SimpleAlgoliaSearchService
  OLLAMA_URL = 'http://localhost:11434'
  
  def initialize
    @algolia_app_id = ENV['ALGOLIA_APP_ID']
    @algolia_api_key = ENV['ALGOLIA_API_KEY'] || ENV['ALGOLIA_SEARCH_KEY']
    @algolia_index = 'Event'
  end

  def ask(user_query, &block)
    Rails.logger.info("🎯 User Query: #{user_query}")
    
    yield "🔍 Searching for events..." if block_given?
    
    begin
      # Step 1: Extract search terms
      search_terms = extract_search_terms(user_query)
      Rails.logger.info("🔎 Search terms: #{search_terms}")
      
      # Step 2: Search Algolia directly
      results = search_algolia(search_terms)
      
      if results.empty?
        Rails.logger.info("⚠️ No results from Algolia")
        fallback_msg = "I couldn't find any events matching '#{user_query}'. Try searching for a different location or check back later!"
        return block_given? ? (yield fallback_msg) : fallback_msg
      end
      
      Rails.logger.info("✅ Found #{results.length} events")
      
      # Step 3: Format events context for Ollama
      events_data = results.map do |event|
        {
          objectID: event['objectID'],
          name: event['name'],
          address: event['address'] || [event['city'], event['state']].compact.join(', '),
          city: event['city'],
          state: event['state'],
          date: format_date(event['started_at'])
        }
      end
      
      # Step 4: Ask Ollama to format the results nicely
      system_prompt = <<~PROMPT
        You are a helpful assistant for finding vendor events. The user asked: "#{user_query}"
        
        Here are #{events_data.length} events found:
        #{JSON.pretty_generate(events_data)}
        
        Format these events in a friendly, helpful way using markdown:
        - Use numbered lists (1., 2., 3.)
        - Use bullet points (•) for event details
        - Use **bold** for event names
        - Include the full address
        - Include the date
        - IMPORTANT: Create clickable event links using this format: [View Event Details](https://govend.ing/events/[objectID])
          Replace [objectID] with the actual objectID from each event
        
        Example format:
        Here are some great events I found for you:
        
        1. **Event Name**
           • 📍 Address: Full Street Address, City, State
           • 📅 Date: Month DD, YYYY
           • 🔗 [View Event Details](https://govend.ing/events/123)
        
        2. **Another Event**
           • 📍 Address: Full Street Address, City, State  
           • 📅 Date: Month DD, YYYY
           • 🔗 [View Event Details](https://govend.ing/events/456)
        
        Be friendly and encouraging!
      PROMPT
      
      ollama_response = call_ollama(system_prompt, "Please format these #{events_data.length} events for me")
      
      return block_given? ? (yield ollama_response) : ollama_response
      
    rescue StandardError => e
      Rails.logger.error("❌ Error: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n"))
      error_msg = "Sorry, I encountered an error while searching. Please try again."
      return block_given? ? (yield error_msg) : error_msg
    end
  end

  private

  def search_algolia(query)
    uri = URI("https://#{@algolia_app_id}-dsn.algolia.net/1/indexes/#{@algolia_index}/query")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path)
    request['X-Algolia-Application-Id'] = @algolia_app_id
    request['X-Algolia-API-Key'] = @algolia_api_key
    request['Content-Type'] = 'application/json'
    
    request.body = {
      query: query,
      hitsPerPage: 10
    }.to_json
    
    Rails.logger.info("📤 Querying Algolia: #{query}")
    response = http.request(request)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      Rails.logger.info("📥 Algolia returned #{data['hits'].length} hits")
      data['hits'] || []
    else
      Rails.logger.error("❌ Algolia error: #{response.code} - #{response.body}")
      []
    end
  end

  def call_ollama(system_message, user_message)
    uri = URI("#{OLLAMA_URL}/api/chat")
    
    payload = {
      model: 'llama3.2:latest',
      messages: [
        { role: 'system', content: system_message },
        { role: 'user', content: user_message }
      ],
      stream: false
    }
    
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    Rails.logger.info("📤 Sending to Ollama")
    response = http.request(request)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data.dig('message', 'content') || 'No response from AI'
    else
      raise "Ollama error: #{response.code} - #{response.body}"
    end
  end

  def extract_search_terms(query)
    # Keep location and important keywords, remove filler words
    # Extract state/city names first
    states = ['texas', 'california', 'florida', 'new york', 'illinois', 'ohio', 
              'kentucky', 'georgia', 'michigan', 'pennsylvania', 'chicago', 
              'austin', 'dallas', 'houston', 'miami', 'atlanta']
    
    query_lower = query.downcase
    
    # Find any mentioned state/city
    found_location = states.find { |loc| query_lower.include?(loc) }
    
    if found_location
      # Return the location - Algolia will match it
      return found_location
    end
    
    # Otherwise, clean up filler words but preserve content
    query.gsub(/\b(can you|please|find|show me|search|looking for|events?|to vend at|in|me|this)\b/i, '').strip
  end

  def format_date(timestamp)
    return 'Date TBD' if timestamp.nil?
    begin
      Time.parse(timestamp.to_s).strftime('%B %d, %Y')
    rescue
      'Date TBD'
    end
  end
end
