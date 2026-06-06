class VendorEventsController < ApplicationController
  before_action :set_vendor_event, only: %i[ show edit calendar update destroy ]
  before_action :set_breadcrumbs, only: %i[show edit new]


  helper CalendarHelper
  include PaginationHelper

  def index
    @vendor_event = VendorEvent.new
    base_scope = current_user.vendor_events.joins(:event)
    @q = base_scope.ransack(params[:q])
    @vendor_events = @q.result.includes(:event).order(start_time: :asc).page(params[:page]).per(10)
    @current_page = @vendor_events.current_page
    @total_pages = @vendor_events.total_pages

  respond_to do |format|
    format.html # Render index.html.erb
    format.js   # Render index.js.erb
  end
  end
  
  def show
    add_breadcrumb "Show", vendor_event_path(@vendor_event), title: @vendor_event.event&.name || "Vendor Event"
    @note ||= Note.new
  end

  def new
    add_breadcrumb "New", new_vendor_event_path, title: "New Event"
    @vendor_event = VendorEvent.new
  end

  def edit
    add_breadcrumb "Edit", edit_vendor_event_path(@vendor_event), title: "Edit Event"
  end

  def create
    event_id = params.dig("vendor_event", "event_id")
    event = Event.find_by(id: event_id)

    if event.blank?
      redirect_back fallback_location: events_path, alert: "Event not found."
      return
    end

    if event.host_id == current_user.id
      redirect_to event_path(event), alert: "You host this event, so it is already tracked under Hosted Events."
      return
    end

    @vendor_event = current_user.vendor_events.find_or_initialize_by(event_id: event.id)
    @vendor_event.assign_attributes(vendor_event_params.except(:event_id))
    @vendor_event.added = true if @vendor_event.added.nil?

    if @vendor_event.save
      redirect_to @vendor_event, notice: "Vendor event was successfully created."
    else
      redirect_to event_path(event), alert: @vendor_event.errors.full_messages.to_sentence
    end
  end

  def update
    if @vendor_event.update(vendor_event_params)
      redirect_to vendor_events_path notice: "Vendor event was successfully updated." 
    else
      render :edit, status: :unprocessable_entity 
    end
  end

  def destroy
    if @vendor_event.destroy
      flash[:notice] = "Removed from your events."
    else
      flash[:alert] = "Unable to delete vendor event."
    end
    redirect_to vendor_events_path
  end

  def calendar
    @vendor_events = VendorEvent.where(user_id: current_user.id).where.not(start_time: nil)
  end

  def update_expenses_and_sales
    if VendorEvent.update_expenses_and_sales(params[:vendor_events])
    redirect_to user_path(current_user), notice: 'Expenses and sales updated successfully.'
    else
      redirect_back(fallback_location: user_path(current_user), alert: 'Unable to update expenses and sales.')
    end
  end

  private

  def set_vendor_event
    @vendor_event = VendorEvent.find(params[:id])
  end

  def vendor_event_params
    params.require(:vendor_event).permit(:address, :name, :description, :date, :location, :photo, :paid, :application_status, :starts_at, :event_id, :user_id, :expenses, :sales, :return, :profit, :start_time)
  end


  def set_breadcrumbs
    add_breadcrumb "Home", :root_path
  end
end
