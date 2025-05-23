class EventsController < ApplicationController
  before_action :set_event, only: %i[ index show new edit update destroy ]
  before_action :event_params, only: %i[ create update ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :set_breadcrumbs, only: %i[ index show edit new ]
  include PaginationHelper


  def index
    pagination = custom_paginate(Event.all, per_page: 5)
    @events = pagination[:collection]
    @current_page = pagination[:current_page]
    @total_pages = pagination[:total_pages]
    add_breadcrumb "Events", events_path, title: "Events"
    @event = Event.new
    @q = Event.ransack(params[:q])
      if @q.started_at
        @events = @q.result.order(started_at: :asc).page(params[:page]).per(6)
      else if @q.name_cont
        @events = @q.result.order(name: :asc).page(params[:page]).per(6)
      else
        @events = @q.result.page(params[:page]).per(6)
      end
    end
  end
  # GET /events/1 or /events/1.json
  def show 
    add_breadcrumb "Events", events_path, title: "Events" 
    add_breadcrumb "Show", event_path(@event), title: @event.name
    @event = Event.find(params[:id])
    @comments = @event.comments.includes(:author)
  end

  def geocode_address
    result = Geocoder.search(params[:address])
    if result.first
      render json: {latitude: result.first.latitude, longitude: result.first.longitude}
    else
      render json: {latitude: nil, longitude: nil}
    end
  end
  # GET /events/new
  def new
    add_breadcrumb "New", new_event_path, title: "New Event"
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    add_breadcrumb "Show", event_path(@event), title: @event.name
    add_breadcrumb "Edit", edit_event_path(@event), title: "Edit Event"
    @event = Event.find(params[:id])
  end

  def add_event
    @vendor_event = VendorEvent.new(event_id: @event.id, user_id: current_user.id)
    format html {redirect_to add_event_vendor_event_path, notice: "Event Updated successfully"}
  end
  # POST /events or /events.json
  def create
    @event = Event.new(event_params)
    @event.host_id = current_user.id
    respond_to do |format|
      if @event.save
        format.html { redirect_to event_url(@event), notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to event_url(@event), notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_photo
    @user = current_user
  end

  def update_photo
    @user = current_user
    if @user.update(user_params)
      redirect_to @user, notice: 'photo was successfully updated.'
    else
      render :edit_user
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy!
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.where(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:photo, :name, :application_due_at, :started_at, :ends_at, :information, :application_link, :tags, :address, :comments, :q, :commit)
  end

  def ensure_user_is_authorized
    if !EventPolicy.new(current_user, @event)
      raise Pundit::NotAuthorizedError, "not allowed"
      end
    end

  def set_breadcrumbs
    add_breadcrumb "Home", :root_path
  end

  def pagination_params
    params.permit(:page)
  end

end
