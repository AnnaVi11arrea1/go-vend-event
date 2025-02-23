# filepath: /workspaces/go-vend-event/app/controllers/geocoding_controller.rb
class GeocodingController < ApplicationController
  def geocode_address
    address = params[:address]
    coordinates = Geocoder.coordinates(address)

    if coordinates
      render json: { latitude: coordinates[0], longitude: coordinates[1] }
    else
      render json: { error: 'Geocoding failed' }, status: :unprocessable_entity
    end
  end
end
