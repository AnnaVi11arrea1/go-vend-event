class VendorEventsController < ApplicationController
  before_action :set_vendor_event, only: %i[ show edit new update destroy]

  # GET /vendor_events or /vendor_events.json
  def index
    @vendor_events = VendorEvent.all.where(:user_id => current_user.id)
  end

  # GET /vendor_events/1 or /vendor_events/1.json
  def show
  end
  # GET /vendor_events/new

  def new
    @vendor_event = VendorEvent.new
  end

  # GET /vendor_events/1/edit
  def edit
  end

  # POST /vendor_events or /vendor_events.json
  def create

    @vendor_event = VendorEvent.new(vendor_event_params)
    @vendor_event.user_id = current_user.id
    @vendor_event.event_id = params.dig("vendor_event", "event_id")
    respond_to do |format|
      if @vendor_event.save
        format.html { redirect_to vendor_events_path, notice: "Vendor event was successfully created." }
        format.json { render :show, status: :created, location: @vendor_event }
      else
        format.html { render :new, status: :unprocessable_entity } #ODO: HANDLE Edge case
        format.json { render json: @vendor_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendor_events/1 or /vendor_events/1.json
  def update
    respond_to do |format|
      if @vendor_event.update(vendor_event_params)
        format.html { redirect_to vendor_event_url(@vendor_event), notice: "Vendor event was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vendor_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # def add_event
  #   @vendor_event = VendorEvent.new(event_id: @event.id, user_id: current_user.id)
  #   respond_to do |format|
  #     if @vendor_event.save
  #       format.html { redirect_to vendor_event_url(@vendor_event), notice: "Event was successfully added to vendor events." }
  #       format.json { render :show, status: :created, location: @vendor_event }
  #     else
  #       format.html { redirect_to events_url, alert: "Failed to add event to vendor events." }
  #       format.json { render json: @vendor_event.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /vendor_events/1 or /vendor_events/1.json
  def destroy
    @vendor_event.destroy!
    respond_to do |format|
      format.html { redirect_to vendor_events_url, notice: "Vendor event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_vendor_event
    @vendor_event = VendorEvent.find(params[:id])
  end

  def vendor_event_params
    params.require(:vendor_event).permit(:name, :description, :date, :location, :photo)
  end
end
