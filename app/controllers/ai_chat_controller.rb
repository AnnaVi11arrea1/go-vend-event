class AiChatsController < ApplicationController
  def create
    user_query = params[:query]
    
    # Orchesrate the service call
    @answer = AlgoliaSearchService.new.ask(user_query, context: "events")
    
    respond_to do |format|
      format.json { render json: { answer: @answer } }
      # Or use Turbo Streams if you want real-time updates
      format.turbo_stream 
    end
  end
end
