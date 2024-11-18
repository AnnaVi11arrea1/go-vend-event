class VendorEventsController < ApplicationController


  # GET /vendor_events or /vendor_events.json
  def index
    @vendor_events = VendorEvent.all
 
  end

  # GET /vendor_events/1 or /vendor_events/1.json
  def show
  end
  # GET /vendor_events/new
  def new
    @vendor_event = VendorEvent.new
    @vendor_event.user_id = current_user.id
    respond_to do |format|
      if @vendor_event.save
        format.html { redirect_to vendor_event, notice: "Vendor event was successfully created." }
        format.json { render :show, status: :created, location: @vendor_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /vendor_events/1/edit
  def edit
  end

  # POST /vendor_events or /vendor_events.json
  def create
    @vendor_event = VendorEvent.new(vendor_event_params)
    @vendor_event.user_id = current_user.id
    respond_to do |format|
      if @vendor_event.save
        format.html { redirect_to vendor_event_url(@vendor_event), notice: "Vendor event was successfully created." }
        format.json { render :show, status: :created, location: @vendor_event }
      else
        format.html { render :new, status: :unprocessable_entity }
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

  def add_event
    @event_id = params.fetch("id")
    @addedEvent = Event.where({added: true})

    @addedEvent.save
    format html {redirect_to event_path, notice: "Event Updated successfully"}
  end

  # DELETE /vendor_events/1 or /vendor_events/1.json
  def destroy
    @vendor_event.destroy!
    respond_to do |format|
      format.html { redirect_to vendor_events_url, notice: "Vendor event was successfully destroyed." }
      format.json { head :no_content }
    end
  end



end
