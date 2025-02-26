require 'httparty'
class EventbriteService
  include HTTParty
  base_uri 'https://www.eventbriteapi.com/v3'
  
  def initialize
    @api_key = ENV['EVENTBRITE_API_KEY']
  end

  def search_events(query)
    # Making the GET request
    response = self.class.get( base_uri + "/events/search/", 
      headers: { "Authorization" => "Bearer #{@api_key}" }, 
      query: { q: query })
      Rails.logger.info "API Response: #{response.inspect}" # Log the full response

      if response.success?
        events = response.parsed_response['events']
        if events.is_a?(Array) # Make sure we return an array
          events
        else
          Rails.logger.error "Expected an array of events but got #{events.class}"
          []
        end
      else
        Rails.logger.error "Eventbrite API Error: #{response.code} - #{response.message}"
        []
      end
  rescue StandardError => e
    Rails.logger.error "Eventbrite API Error: #{e.class} - #{e.message}"
  end
end
