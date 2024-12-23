class ApplicationController < ActionController::Base
  include Pundit
  helper :all
  
  skip_forgery_protection

  before_action :configure_permitted_parameters, if: :devise_controller?
 
protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :photo])
  devise_parameter_sanitizer.permit(:account_update, keys: [:username, :photo])
end

end
