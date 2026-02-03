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
      # Step 1: Check if query contains a zipcode for geo search
      zipcode = extract_zipcode(user_query)
      results = []
      
      if zipcode
        Rails.logger.info("📍 Zipcode detected: #{zipcode}")
        results = search_by_zipcode(zipcode, user_query)
      else
        # Step 2: Extract search terms
        search_terms = extract_search_terms(user_query)
        Rails.logger.info("🔎 Search terms: #{search_terms}")
        
        # Step 3: Search Algolia directly
        results = search_algolia(search_terms, user_query)
      end
      
      if results.empty?
        Rails.logger.info("⚠️ No results from Algolia")
        fallback_msg = "I couldn't find any events matching '#{user_query}'. Try searching for a different location or check back later!"
        return block_given? ? (yield fallback_msg) : fallback_msg
      end
      
      Rails.logger.info("✅ Found #{results.length} events")
      
      # Step 3: Format events context for Ollama
      events_data = results.map do |event|
        data = {
          objectID: event['objectID'],
          name: event['name'],
          address: event['address'] || [event['city'], event['state']].compact.join(', '),
          city: event['city'],
          state: event['state'],
          date: format_date(event['started_at'])
        }
        
        # Add distance if available (from geo search)
        if event['_rankingInfo'] && event['_rankingInfo']['geoDistance']
          distance_km = (event['_rankingInfo']['geoDistance'] / 1000.0).round(1)
          distance_miles = (distance_km * 0.621371).round(1)
          data[:distance] = "#{distance_miles} miles away"
        end
        
        data
      end

      # Step 4: Ask Ollama to format the results nicely
      location_context = zipcode ? "near zipcode #{zipcode}" : "matching your search"
      
      # Get the base URL for the application
      base_url = ENV['APP_URL'] || 'http://localhost:3000'
      
      system_prompt = <<~PROMPT
        You are a helpful assistant for finding vendor events. The user asked: "#{user_query}"

        Here are #{events_data.length} events found #{location_context}:
        #{JSON.pretty_generate(events_data)}

        Format these events in a friendly, helpful way using markdown:
        - Use numbered lists (1., 2., 3.)
        - Use bullet points (•) for event details
        - Use **bold** for event names
        - Include the full address
        - Include the date
        - If distance is provided, include it with a 📏 emoji
        - IMPORTANT: Create clickable event links using this format: [View Event Details](#{base_url}/events/[objectID])
          Replace [objectID] with the actual objectID from each event

        Example format:
        Here are some great events I found for you#{zipcode ? " near #{zipcode}" : ""}:

        1. **Event Name**
           • 📍 Address: Full Street Address, City, State
           • 📅 Date: Month DD, YYYY
           #{zipcode ? "• 📏 Distance: X miles away\n           " : ""}• 🔗 [View Event Details](#{base_url}/events/123)

        2. **Another Event**
           • 📍 Address: Full Street Address, City, State
           • 📅 Date: Month DD, YYYY
           #{zipcode ? "• 📏 Distance: X miles away\n           " : ""}• 🔗 [View Event Details](#{base_url}/events/456)

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

  def search_algolia(query, original_query = nil)
    uri = URI("https://#{@algolia_app_id}-dsn.algolia.net/1/indexes/#{@algolia_index}/query")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request['X-Algolia-Application-Id'] = @algolia_app_id
    request['X-Algolia-API-Key'] = @algolia_api_key
    request['Content-Type'] = 'application/json'

    # Add date filters for seasonal queries
    filters = build_date_filters(original_query || query)

    body = {
      query: query,
      hitsPerPage: 10
    }
    
    body[:filters] = filters if filters.present?

    request.body = body.to_json

    Rails.logger.info("🔎 Querying Algolia: #{query}")
    Rails.logger.info("📅 Filters: #{filters}") if filters.present?
    
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      hits = data['hits'] || []
      Rails.logger.info("📥 Algolia returned #{hits.length} hits")
      
      # If no results with filters, try without filters
      if hits.empty? && filters.present?
        Rails.logger.info("🔄 Retrying without date filters...")
        body.delete(:filters)
        request.body = body.to_json
        
        retry_response = http.request(request)
        if retry_response.is_a?(Net::HTTPSuccess)
          retry_data = JSON.parse(retry_response.body)
          hits = retry_data['hits'] || []
          Rails.logger.info("📥 Retry returned #{hits.length} hits")
        end
      end
      
      hits
    else
      Rails.logger.error("❌ Algolia error: #{response.code} - #{response.body}")
      []
    end
  end

  def search_by_zipcode(zipcode, original_query)
    # Geocode the zipcode to get lat/lng
    begin
      location = Geocoder.search(zipcode).first
      
      unless location
        Rails.logger.warn("⚠️ Could not geocode zipcode: #{zipcode}")
        return []
      end

      lat = location.latitude
      lng = location.longitude
      
      Rails.logger.info("📍 Geocoded #{zipcode} to: #{lat}, #{lng}")

      # Search Algolia with geo location
      uri = URI("https://#{@algolia_app_id}-dsn.algolia.net/1/indexes/#{@algolia_index}/query")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request['X-Algolia-Application-Id'] = @algolia_app_id
      request['X-Algolia-API-Key'] = @algolia_api_key
      request['Content-Type'] = 'application/json'

      # Determine radius based on query keywords
      radius = original_query.match?(/\b(near|nearby|close|around)\b/i) ? 50_000 : 100_000 # 50km or 100km in meters
      
      # Add date filters
      filters = build_date_filters(original_query)

      body = {
        aroundLatLng: "#{lat}, #{lng}",
        aroundRadius: radius,
        hitsPerPage: 10,
        getRankingInfo: true
      }
      
      body[:filters] = filters if filters.present?

      request.body = body.to_json

      Rails.logger.info("🔎 Searching near #{zipcode} (#{lat}, #{lng}) within #{radius/1000}km")
      
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        Rails.logger.info("📥 Found #{data['hits'].length} events near #{zipcode}")
        data['hits'] || []
      else
        Rails.logger.error("❌ Algolia geo search error: #{response.code} - #{response.body}")
        []
      end

    rescue StandardError => e
      Rails.logger.error("❌ Zipcode search error: #{e.message}")
      []
    end
  end

  def build_date_filters(query)
    return nil if query.blank?
    
    query_lower = query.downcase
    current_year = Time.current.year
    
    # Spring: March 20 - June 20
    if query_lower.include?('spring')
      spring_start = Time.new(current_year, 3, 20).to_i
      spring_end = Time.new(current_year, 6, 20).to_i
      return "started_at_timestamp:#{spring_start} TO #{spring_end}"
    end
    
    # Summer: June 21 - September 22
    if query_lower.include?('summer')
      summer_start = Time.new(current_year, 6, 21).to_i
      summer_end = Time.new(current_year, 9, 22).to_i
      return "started_at_timestamp:#{summer_start} TO #{summer_end}"
    end
    
    # Fall/Autumn: September 23 - December 20
    if query_lower.include?('fall') || query_lower.include?('autumn')
      fall_start = Time.new(current_year, 9, 23).to_i
      fall_end = Time.new(current_year, 12, 20).to_i
      return "started_at_timestamp:#{fall_start} TO #{fall_end}"
    end
    
    # Winter: December 21 - March 19 (next year)
    if query_lower.include?('winter')
      winter_start = Time.new(current_year, 12, 21).to_i
      winter_end = Time.new(current_year + 1, 3, 19).to_i
      return "started_at_timestamp:#{winter_start} TO #{winter_end}"
    end
    
    nil
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

  def extract_zipcode(query)
    # Match 5-digit zipcode or ZIP+4 format
    match = query.match(/\b(\d{5})(?:-\d{4})?\b/)
    match ? match[1] : nil
  end

  def extract_search_terms(query)
    # Keep location and important keywords, remove filler words
    # Extract state/city names and seasons
    states = ['alabama', 'alaska', 'arizona', 'arkansas', 'california', 'colorado', 
              'connecticut', 'delaware', 'florida', 'georgia', 'hawaii', 'idaho',
              'illinois', 'indiana', 'iowa', 'kansas', 'kentucky', 'louisiana',
              'maine', 'maryland', 'massachusetts', 'michigan', 'minnesota',
              'mississippi', 'missouri', 'montana', 'nebraska', 'nevada',
              'new hampshire', 'new jersey', 'new mexico', 'new york',
              'north carolina', 'north dakota', 'ohio', 'oklahoma', 'oregon',
              'pennsylvania', 'rhode island', 'south carolina', 'south dakota',
              'tennessee', 'texas', 'utah', 'vermont', 'virginia', 'washington',
              'west virginia', 'wisconsin', 'wyoming', 'chicago', 'austin', 
              'dallas', 'houston', 'miami', 'atlanta', 'seattle', 'portland',
              'denver', 'phoenix', 'boston', 'philadelphia', 'nashville']
    
    # Seasons and time periods
    time_keywords = ['spring', 'summer', 'fall', 'autumn', 'winter', 'january', 
                     'february', 'march', 'april', 'may', 'june', 'july', 'august',
                     'september', 'october', 'november', 'december', 'weekend',
                     'month', 'week', 'today', 'tomorrow', 'soon']

    query_lower = query.downcase

    # Find any mentioned state/city
    found_locations = states.select { |loc| query_lower.include?(loc) }
    found_times = time_keywords.select { |time| query_lower.include?(time) }

    # Combine location and time terms
    search_terms = (found_locations + found_times).join(' ')

    if search_terms.present?
      return search_terms
    end

    # Otherwise, clean up filler words but preserve content
    cleaned = query.gsub(/\b(can you|please|find|show me|search|looking for|events?|to vend at|in|me|this|for|the|a|an|near|around|zipcode|zip)\b/i, '').strip
    cleaned.present? ? cleaned : query
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
