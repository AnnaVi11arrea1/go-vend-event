require 'net/http'
require 'json'

class EventSimilarityService
  def initialize
    @app_id = ENV['ALGOLIA_APP_ID']
    @api_key = ENV['ALGOLIA_API_KEY'] || ENV['ALGOLIA_SEARCH_KEY']
    @index_name = 'Event'
  end

  # Get similar events based on attributes (location, tags, date)
  def get_similar_events(event, max_results: 6)
    return [] if event.nil?
    
    Rails.logger.info("🔍 Finding similar events to: #{event.name}")
    
    # Build search query based on event attributes
    search_queries = build_similarity_queries(event)
    
    # Search Algolia with multiple strategies
    similar_event_ids = Set.new
    
    search_queries.each do |query_config|
      results = search_algolia(query_config[:query], query_config[:filters])
      
      results.each do |hit|
        # Don't include the original event
        next if hit['objectID'].to_s == event.id.to_s
        similar_event_ids.add(hit['objectID'].to_i)
        break if similar_event_ids.size >= max_results
      end
      
      break if similar_event_ids.size >= max_results
    end
    
    Rails.logger.info("✅ Found #{similar_event_ids.size} similar events")
    
    # Return Event objects in order of relevance
    Event.where(id: similar_event_ids.to_a).limit(max_results)
  end

  private

  def build_similarity_queries(event)
    queries = []
    
    # Strategy 1: Same state + similar tags/keywords
    if event.state.present?
      search_terms = extract_keywords(event)
      queries << {
        query: search_terms,
        filters: "state:#{event.state}"
      }
    end
    
    # Strategy 2: Same city (more specific)
    if event.city.present?
      queries << {
        query: extract_keywords(event),
        filters: "city:#{event.city}"
      }
    end
    
    # Strategy 3: Similar timeframe (same month/season) - removed for now
    # Date filtering is complex with Algolia, skip for simplicity
    
    # Strategy 4: Just tags/keywords with no location filter (fallback)
    queries << {
      query: extract_keywords(event),
      filters: nil
    }
    
    queries
  end

  def extract_keywords(event)
    keywords = []
    
    # Extract from tags
    if event.tags.present?
      keywords << event.tags.split(',').map(&:strip).join(' ')
    end
    
    # Extract key words from name (remove common words)
    if event.name.present?
      name_words = event.name.downcase
        .gsub(/\b(2024|2025|2026|the|and|at|in|festival|fair|market|event)\b/, '')
        .strip
      keywords << name_words if name_words.length > 3
    end
    
    keywords.join(' ').strip
  end

  def search_algolia(query, filters)
    return [] if query.blank?
    
    uri = URI("https://#{@app_id}-dsn.algolia.net/1/indexes/#{@index_name}/query")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 5
    
    request = Net::HTTP::Post.new(uri.path)
    request['X-Algolia-Application-Id'] = @app_id
    request['X-Algolia-API-Key'] = @api_key
    request['Content-Type'] = 'application/json'
    
    payload = {
      query: query,
      hitsPerPage: 10
    }
    payload[:filters] = filters if filters.present?
    
    request.body = payload.to_json
    
    response = http.request(request)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data['hits'] || []
    else
      Rails.logger.error("❌ Algolia Search Error: #{response.code}")
      []
    end
  rescue StandardError => e
    Rails.logger.error("❌ Similarity Search Error: #{e.message}")
    []
  end
end
