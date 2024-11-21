class EventsController < ApplicationController
  before_action :set_event, only: %i[ index show new edit update destroy ]
  before_action :event_params, only: %i[ create update ]
  # before_action :authenticate_user!, only: %i[ new create edit update destroy ]

  # GET /events or /events.json
  def index
    @vendor_event = VendorEvent.new

    @q = Event.ransack(params[:q])
    
    @events = Event.page(params[:page]).per(5)
  end
  
  # GET /events/1 or /events/1.json
  def show
    @event = Event.find(params[:id])
    @host = User.find(@event.host_id)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
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
    @event = Event.where(id: params[:id]).first
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:photo, :name, :application_due_at, :started_at, :information, :application_link, :tags, :address)
  end

  
end
