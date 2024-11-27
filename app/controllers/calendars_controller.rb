class CalendarsController < ApplicationController
def show
  @vendor_event = VendorEvent.find(params[:vendor_event_id])
end
