class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper :all

  before_action :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery with: :exception
  
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
