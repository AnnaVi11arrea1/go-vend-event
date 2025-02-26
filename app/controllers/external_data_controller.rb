class ExternalDataController < ApplicationController
  def index
    if params[:query].present?
      eventbrite_service = EventbriteService.new
      @events = eventbrite_service.search_events(params[:query])
    else
      @events = []
    end
  end
end
