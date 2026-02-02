# Algolia Recommend Implementation Guide for Events

## Step 1: Track User Events

First, you need to send events to Algolia whenever users interact with events:

```ruby
# app/models/event.rb or wherever you track views/applications

class Event < ApplicationRecord
  # ... existing code ...
  
  # Track when a user views an event
  def track_view(user)
    AlgoliaEventTracker.track_view(
      user_token: user.id.to_s,
      event_id: self.id
    )
  end
  
  # Track when a user applies/books an event
  def track_application(user)
    AlgoliaEventTracker.track_conversion(
      user_token: user.id.to_s,
      event_id: self.id
    )
  end
end
```

## Step 2: Create Event Tracking Service

```ruby
# app/services/algolia_event_tracker.rb

require 'net/http'
require 'json'

class AlgoliaEventTracker
  ALGOLIA_APP_ID = ENV['ALGOLIA_APP_ID']
  ALGOLIA_API_KEY = ENV['ALGOLIA_API_KEY']
  ALGOLIA_INDEX = 'Event'
  
  def self.track_view(user_token:, event_id:)
    send_event(
      eventType: 'click',
      eventName: 'Event Viewed',
      index: ALGOLIA_INDEX,
      userToken: user_token,
      objectIDs: [event_id.to_s],
      timestamp: (Time.now.to_f * 1000).to_i
    )
  end
  
  def self.track_conversion(user_token:, event_id:)
    send_event(
      eventType: 'conversion',
      eventName: 'Event Application Submitted',
      index: ALGOLIA_INDEX,
      userToken: user_token,
      objectIDs: [event_id.to_s],
      timestamp: (Time.now.to_f * 1000).to_i
    )
  end
  
  private
  
  def self.send_event(event_data)
    uri = URI('https://insights.algolia.io/1/events')
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path)
    request['X-Algolia-Application-Id'] = ALGOLIA_APP_ID
    request['X-Algolia-API-Key'] = ALGOLIA_API_KEY
    request['Content-Type'] = 'application/json'
    
    request.body = {
      events: [event_data]
    }.to_json
    
    response = http.request(request)
    Rails.logger.info("📊 Algolia Event Tracked: #{event_data[:eventName]}")
    
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("❌ Algolia Event Error: #{response.body}")
    end
  rescue StandardError => e
    Rails.logger.error("❌ Event Tracking Error: #{e.message}")
  end
end
```

## Step 3: Add Tracking to Controllers

```ruby
# app/controllers/events_controller.rb

def show
  @event = Event.find(params[:id])
  
  # Track the view if user is signed in
  if current_user
    @event.track_view(current_user)
  end
  
  # Get related events (once Recommend is set up)
  @related_events = get_related_events(@event.id)
end

def apply
  @event = Event.find(params[:id])
  
  # ... your application logic ...
  
  # Track conversion
  if current_user
    @event.track_application(current_user)
  end
end

private

def get_related_events(event_id)
  # This will work after you enable Recommend in Algolia Dashboard
  uri = URI("https://#{ENV['ALGOLIA_APP_ID']}-dsn.algolia.net/1/indexes/*/recommendations")
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.path)
  request['X-Algolia-Application-Id'] = ENV['ALGOLIA_APP_ID']
  request['X-Algolia-API-Key'] = ENV['ALGOLIA_API_KEY']
  request['Content-Type'] = 'application/json'
  
  request.body = {
    requests: [
      {
        indexName: 'Event',
        model: 'related-products', # or 'bought-together', 'trending-items'
        objectID: event_id.to_s,
        maxRecommendations: 5
      }
    ]
  }.to_json
  
  response = http.request(request)
  
  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    data.dig('results', 0, 'hits') || []
  else
    []
  end
end
```

## Step 4: Display Recommendations in View

```erb
<!-- app/views/events/show.html.erb -->

<div class="event-details">
  <h1><%= @event.name %></h1>
  <!-- ... existing event details ... -->
</div>

<% if @related_events.present? %>
  <div class="related-events mt-5">
    <h3>Similar Events You Might Like</h3>
    <div class="row">
      <% @related_events.each do |event_data| %>
        <div class="col-md-4">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title"><%= event_data['name'] %></h5>
              <p class="card-text">
                📍 <%= event_data['city'] %>, <%= event_data['state'] %><br>
                📅 <%= event_data['started_at'] %>
              </p>
              <%= link_to 'View Details', event_path(event_data['objectID']), class: 'btn btn-primary' %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
  </div>
<% end %>
```

## Step 5: Enable in Algolia Dashboard

1. Go to https://www.algolia.com/apps/[YOUR_APP]/recommend
2. Click "Create Recommendation Model"
3. Choose:
   - **Related Items** (needs 10,000+ click/conversion events)
   - **Looking Similar** (works immediately, no events needed!)
   - **Trending Items** (needs 250+ conversion events)
4. Select your "Event" index
5. Click "Create"

## Quick Win: Looking Similar (No Events Required!)

If you want recommendations NOW without waiting for event data:

```ruby
# Configure which attributes to use for similarity
# In Algolia Dashboard → Recommend → Looking Similar:
# - Set attributes: ['name', 'city', 'state', 'event_type']

def get_similar_events_by_content(event_id)
  uri = URI("https://#{ENV['ALGOLIA_APP_ID']}-dsn.algolia.net/1/indexes/*/recommendations")
  
  # ... HTTP setup same as above ...
  
  request.body = {
    requests: [
      {
        indexName: 'Event',
        model: 'looking-similar', # Uses content attributes
        objectID: event_id.to_s,
        maxRecommendations: 5
      }
    ]
  }.to_json
  
  # ... send request and return results ...
end
```

## Use Cases for Your Platform:

1. **Event Detail Page**: "Similar events nearby"
2. **Homepage**: "Trending events this week"
3. **After Application**: "Vendors who applied here also applied to..."
4. **Search Results**: "You might also like..."
5. **Email Campaigns**: "Recommended events for you"

## Notes:

- Event tracking is anonymous until user logs in
- Use user ID as `userToken` for logged-in users
- Use session ID or device fingerprint for anonymous users
- Models retrain daily automatically
- Takes 24-48 hours to collect enough data for collaborative filtering models
