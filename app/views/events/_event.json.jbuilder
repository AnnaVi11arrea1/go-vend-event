json.extract! event, :id, :name, :application_due_at, :started_at, :information, :application_link, :tags, :address, :host_id, :created_at, :updated_at
json.url event_url(event, format: :json)
