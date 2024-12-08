class VendorEventsController < ApplicationController
  before_action :set_vendor_event, only: %i[ show edit new update calendar update destroy ]

  # GET /vendor_events or /vendor_events.json
  def index
    @vendor_events = VendorEvent.all.where(:user_id => current_user.id).page(params[:page]).per(10)
    @vendor_event = VendorEvent.all.where("start_time < ?", Date.today)
    @a = Event.ransack(params[:a])
      if @a.started_at
        @events = @a.result.order(started_at: :asc).page(params[:page]).per(5)
      else if @a.name_cont
        @events = @a.result.order(name: :asc).page(params[:page]).per(5)
      else
        @events = @a.result.page(params[:page]).per(5)
      end
    end
  end
  
  # GET /vendor_events/1 or /vendor_events/1.json
  def show
    @vendor_events = VendorEvent.all.where(:host_id => current_user.id)
    @vendor_event = VendorEvent.find(params[:id])
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
    @vendor_event.reverse_geocode
    @vendor_event.save!
    respond_to do |format|
      if @vendor_event.save
        format.html { redirect_to vendor_event_path(@vendor_event), notice: "Vendor event was successfully created." }
        format.json { render :index, status: :created, location: @vendor_event }
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
  # DELETE /vendor_events/1 or /vendor_events/1.json
  def destroy
    @vendor_event = VendorEvent.find(params[:id])
    if @vendor_event.destroy
      flash[:notice] = "Vendor event deleted successfully."
      redirect_to vendor_events_path
    else
      flash[:alert] = "Unable to delete vendor event."
      redirect_back(fallback_location: vendor_events_path)
    end
  end

  def calendar
  end

  def update_expenses_and_sales
    params[:vendor_events].each do |id, attributes|
      vendor_event = VendorEvent.find(id)
      vendor_event.update(attributes.permit(:expense, :sales, :return, :profit))
    end
    redirect_to user_path(current_user), notice: 'Expenses and sales updated successfully.'
  end

  private

  def set_vendor_event
    @vendor_event = VendorEvent.find(params[:id])
  end

  def vendor_event_params
    params.require(:vendor_event).permit(:name, :description, :date, :location, :photo, :paid, :application_status, :starts_at, :event_id, :user_id, :expenses, :sales, :return, :profit)
  end



end
