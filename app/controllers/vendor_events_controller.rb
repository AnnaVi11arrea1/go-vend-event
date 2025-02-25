class VendorEventsController < ApplicationController
  before_action :set_vendor_event, only: %i[ show edit calendar update destroy ]
  before_action :set_breadcrumbs, only: %i[show edit new]


  helper CalendarHelper
  include PaginationHelper

  def index
    pagination = custom_paginate(Event.all, per_page: 10)
    @vendor_events = pagination[:collection]
    @current_page = pagination[:current_page]
    @total_pages = pagination[:total_pages]
    @vendor_event = VendorEvent.new
    @q = VendorEvent.ransack(params[:q])
    if @q.name_cont
      @vendor_events = @q.result.order(name: :asc).page(params[:page]).per(10)
    else
      @vendor_events = @q.result.page(params[:page]).per(10)
    end
    @vendor_events = @q.result.order(start_time: :asc).page(params[:page]).per(10)
  respond_to do |format|
    format.html # Render index.html.erb
    format.js   # Render index.js.erb
  end
  end
  
  def show
    add_breadcrumb "Show", vendor_event_path(@vendor_event), title: @vendor_event.event.name
  end

  def new
    add_breadcrumb "New", new_vendor_event_path, title: "New Event"
    @vendor_event = VendorEvent.new
  end

  def edit
    add_breadcrumb "Edit", edit_vendor_event_path(@vendor_event), title: "Edit Event"
  end

  def create
    @vendor_event = current_user.vendor_events.build(vendor_event_params.merge(event_id: params.dig("vendor_event", "event_id")))
      if @vendor_event.save
        redirect_to @vendor_event, notice: "Vendor event was successfully created." 
      else
        render :new, status: :unprocessable_entity 
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
      flash[:notice] = "Vendor event deleted successfully."
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
