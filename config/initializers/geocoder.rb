Geocoder.configure(
  # Geocoding options
  timeout: 5,                 # geocoding service timeout (secs)
  lookup: :google,            # name of geocoding service (symbol)
  api_key: ENV['GOOGLE_MAPS'], # API key for geocoding service
  units: :mi                  # :km for kilometers or :mi for miles
)
# Geocoding service
