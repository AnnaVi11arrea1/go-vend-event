Geocoder.configure(
  # Geocoding options
  timeout: 5,                 # geocoding service timeout (secs)
  lookup: :mapbox,            # name of geocoding service (symbol)
  api_key: ENV['MAPBOX_ACCESS_TOKEN'], # API key for geocoding service
  units: :mi                  # :km for kilometers or :mi for miles
)
# Geocoding service
