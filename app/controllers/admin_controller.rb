class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @admin_users = User.where(admin: true)
    @stats = {
      users: User.count,
      events: Event.count,
      vendor_events: VendorEvent.count,
      open_tickets: Ticket.open.count,
      unresolved_tickets: Ticket.where.not(status: :resolved).count
    }

    @warnings = []
    @warnings << "There are #{Ticket.old_open.count} open tickets older than 72 hours." if Ticket.old_open.exists?
    @warnings << "There are #{Ticket.unanswered.where.not(status: :resolved).count} unresolved tickets without an admin response." if Ticket.unanswered.where.not(status: :resolved).exists?

    missing_env = %w[ALGOLIA_APP_ID ALGOLIA_SEARCH_KEY MAPBOX_ACCESS_TOKEN].select { |key| ENV[key].blank? }
    @warnings << "Missing API configuration: #{missing_env.join(', ')}" if missing_env.any?

    @recent_tickets = Ticket.includes(:user).order(created_at: :desc).limit(10)
  end

  private

  def check_admin
    unless current_user.admin?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
