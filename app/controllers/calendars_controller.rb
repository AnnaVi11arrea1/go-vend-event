class CalendarsController < ApplicationController
  def show
    @vendor_events = VendorEvent.all
  end
end
