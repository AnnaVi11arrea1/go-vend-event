class ChatController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:message]

  def message
    user_message = params[:message]
    
    if user_message.blank?
      return render json: { error: 'Message cannot be empty' }, status: :bad_request
    end

    # Search for relevant events
    events = search_events_structured(user_message)
    
    # Build context for Ollama
    events_context = events.present? ? format_events_for_ollama(events) : nil
    
    # Get AI response from Ollama
    ollama_service = OllamaService.new
    ai_response = ollama_service.chat(user_message, events_context)
    
    render json: {
      response: ai_response,
      events: events.present? ? events.map { |e| event_json(e) } : [],
      events_found: events.present?
    }
  rescue StandardError => e
    Rails.logger.error("Chat Error: #{e.message}")
    render json: { 
      error: 'Sorry, I encountered an error. Please try again.',
      details: e.message 
    }, status: :internal_server_error
  end

  def search_events_structured(query)
    # First try Algolia search
    Rails.logger.info("🔍 Searching Algolia for: #{query}")
    
    begin
      results = Event.search(query, hitsPerPage: 10)
      Rails.logger.info("📊 Algolia results count: #{results.count}")
      
      if results.present? && !results.empty?
        return results.to_a
      end
    rescue StandardError => e
      Rails.logger.error("Algolia Search Error: #{e.message}")
    end
    
    # Fallback to database search
    Rails.logger.info("🔄 Falling back to database search")
    db_results = database_search(query)
    
    if db_results.present?
      db_results.to_a
    else
      Rails.logger.warn("⚠️ No results found for query: #{query}")
      []
    end
  end

  private

  def database_search(query)
    # Extract potential location keywords
    query_lower = query.downcase
    
    # Common state names and abbreviations
    states = {
      'kentucky' => 'KY', 'texas' => 'TX', 'california' => 'CA', 
      'illinois' => 'IL', 'chicago' => 'IL', 'new york' => 'NY',
      'florida' => 'FL', 'ohio' => 'OH', 'michigan' => 'MI'
    }
    
    # Find matching state
    state_match = states.find { |name, abbr| query_lower.include?(name) }
    
    if state_match
      state_name, state_abbr = state_match
      Rails.logger.info("🎯 Searching for state: #{state_name} (#{state_abbr})")
      
      # Search by state or city
      Event.where("LOWER(state) = ? OR LOWER(state) = ? OR LOWER(city) LIKE ?", 
                  state_abbr.downcase, state_name, "%#{state_name}%")
           .limit(10)
    else
      # General search across all text fields
      Event.where("LOWER(name) LIKE ? OR LOWER(city) LIKE ? OR LOWER(address) LIKE ?",
                  "%#{query_lower}%", "%#{query_lower}%", "%#{query_lower}%")
           .limit(10)
    end
  end

  def format_events_for_ollama(events)
    events.map.with_index(1) do |event, index|
      date = event.started_at ? event.started_at.strftime('%B %d, %Y') : 'Date TBD'
      location = [event.city, event.state].compact.join(', ')
      location = event.address if location.blank?
      "#{index}. #{event.name} in #{location} on #{date}"
    end.join("\n")
  end

  def event_json(event)
    {
      id: event.id,
      name: event.name,
      city: event.city,
      state: event.state,
      address: event.address,
      started_at: event.started_at&.strftime('%B %d, %Y'),
      url: event_url(event)
    }
  end
end
