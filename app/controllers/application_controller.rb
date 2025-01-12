class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper :all
  
  skip_forgery_protection

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_event
  
  def current_event
    @current_event ||= Event.find_by(id: session[:event_id])
  end


  protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :photo])
  devise_parameter_sanitizer.permit(:account_update, keys: [:username, :photo])
end


end
