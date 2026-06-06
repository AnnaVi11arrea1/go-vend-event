module Admin
  class TicketsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_ticket, only: [:show, :update]

    def index
      @status_filter = params[:status].presence
      @tickets = Ticket.includes(:user, :responded_by).order(created_at: :desc)
      @tickets = @tickets.where(status: @status_filter) if @status_filter
    end

    def show
    end

    def update
      if @ticket.update(admin_ticket_params)
        if @ticket.admin_response.present?
          @ticket.update_columns(responded_by_id: current_user.id, responded_at: Time.current)
        end

        redirect_to admin_ticket_path(@ticket), notice: "Ticket updated."
      else
        flash.now[:alert] = "Unable to update ticket."
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_ticket
      @ticket = Ticket.includes(:user, :responded_by).find(params[:id])
    end

    def admin_ticket_params
      params.require(:ticket).permit(:status, :admin_response)
    end

    def require_admin!
      return if current_user.admin?

      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
