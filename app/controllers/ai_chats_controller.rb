class AiChatsController < ApplicationController
  def create
    user_query = params[:query]
    
    if user_query.blank?
      return render json: { error: 'Query cannot be empty' }, status: :bad_request
    end

    # Use the Algolia MCP + Ollama service
    service = AlgoliaSearchService.new
    answer = service.ask(user_query)
    
    render json: { answer: answer }
  rescue StandardError => e
    Rails.logger.error("Chat Error: #{e.message}")
    render json: { error: 'An error occurred', details: e.message }, status: :internal_server_error
  end
end
