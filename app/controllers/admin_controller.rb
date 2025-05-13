class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @admin_user = User.where(admin: true)
  end

  private

  def check_admin
    unless current_user.admin?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
