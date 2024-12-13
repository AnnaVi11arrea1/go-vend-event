class CalendarsController < ApplicationController
  helper CalendarHelper

  def show
    @vendor_events = VendorEvent.all
  end
end
