class ChartsController < ApplicationController
    STATE_ABBREVIATIONS = {
  "Alabama" => "AL",
  "Alaska" => "AK",
  "Arizona" => "AZ",
  "Arkansas" => "AR",
  "California" => "CA",
  "Colorado" => "CO",
  "Connecticut" => "CT",
  "Delaware" => "DE",
  "Florida" => "FL",
  "Georgia" => "GA",
  "Hawaii" => "HI",
  "Idaho" => "ID",
  "Illinois" => "IL",
  "Indiana" => "IN",
  "Iowa" => "IA",
  "Kansas" => "KS",
  "Kentucky" => "KY",
  "Louisiana" => "LA",
  "Maine" => "ME",
  "Maryland" => "MD",
  "Massachusetts" => "MA",
  "Michigan" => "MI",
  "Minnesota" => "MN",
  "Mississippi" => "MS",
  "Missouri" => "MO",
  "Montana" => "MT",
  "Nebraska" => "NE",
  "Nevada" => "NV",
  "New Hampshire" => "NH",
  "New Jersey" => "NJ",
  "New Mexico" => "NM",
  "New York" => "NY",
  "North Carolina" => "NC",
  "North Dakota" => "ND",
  "Ohio" => "OH",
  "Oklahoma" => "OK",
  "Oregon" => "OR",
  "Pennsylvania" => "PA",
  "Rhode Island" => "RI",
  "South Carolina" => "SC",
  "South Dakota" => "SD",
  "Tennessee" => "TN",
  "Texas" => "TX",
  "Utah" => "UT",
  "Vermont" => "VT",
  "Virginia" => "VA",
  "Washington" => "WA",
  "West Virginia" => "WV",
  "Wisconsin" => "WI",
  "Wyoming" => "WY"
}

  def proxy
    url = "https://cdn.fusioncharts.com/fusioncharts/latest/fusioncharts.js"
    response = Net::HTTP.get(URI(url))
    render js: response
   end

  def index
    @vendor_events = VendorEvent.includes(:event).where(user_id: current_user.id)
 # Ensure state is populated
  
    vendor_events_by_state = @vendor_events.group(:state).count

    @chart_data = {
      "chart": {
        "caption": "My popular places",
        "subCaption": "Take the world by storm!",
        "theme": "fusion",
        "showLabels": "1",
        "formatNumberScale": "0"
      },
      "colorrange": {
        "minvalue": "0",
        "startlabel": "Low",
        "endlabel": "High",
        "code": "#FF4411",
        "gradient": "1",
        "color": [
            { "maxvalue": "2", "code": "#FFDD44", "displayValue": "Median" },
            { "maxvalue": "5", "code": "#6baa01" }
          ]
        },
    "data": vendor_events_by_state.map do |state, count|
        abbreviation = STATE_ABBREVIATIONS[state] || "Unknown"
        {
            "id": abbreviation,
            "value": count
          }
        end
    }
end
end
