json.extract! event, :id, :name, :started_at, :application_due_at, :information, :application_link, :tags, :address, :latitude, :longitude, :created_at, :updated_at
json.url event_url(event, format: :json)
