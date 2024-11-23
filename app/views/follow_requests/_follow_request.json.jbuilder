json.extract! follow_request, :id, :recipient_id, :sender_id, :status, :created_at, :updated_at
json.url follow_request_url(follow_request, format: :json)
