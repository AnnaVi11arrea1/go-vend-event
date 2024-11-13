json.extract! vendor_event, :id, :event_id, :application_status, :paid, :user_id, :created_at, :updated_at
json.url vendor_event_url(vendor_event, format: :json)
