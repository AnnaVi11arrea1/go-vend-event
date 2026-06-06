class TicketsController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = current_user.tickets.order(created_at: :desc)
  end

  def new
    @ticket = current_user.tickets.new
  end

  def create
    @ticket = current_user.tickets.new(ticket_params)

    if @ticket.save
      redirect_to tickets_path, notice: "Ticket submitted. We will get back to you soon."
    else
      flash.now[:alert] = "Please fix the highlighted errors."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @ticket = current_user.tickets.find(params[:id])
  end

  private

  def ticket_params
    params.require(:ticket).permit(:subject, :message)
  end
end
