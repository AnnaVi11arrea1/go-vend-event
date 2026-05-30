import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    token: String,
    events: Array,
    defaultPhotoUrl: String
  }

  connect() {
    if (!this.tokenValue) {
      console.error("Mapbox token is missing")
      return
    }

    mapboxgl.accessToken = this.tokenValue
    
    this.map = new mapboxgl.Map({
      container: this.element,
      style: 'mapbox://styles/mapbox/dark-v11',
      center: [-87.61936464305545, 41.87657590074282],
      zoom: 5
    })

    this.map.on('load', () => {
      this.addMarkers()
    })
  }

  addMarkers() {
    this.eventsValue.forEach((event) => {
      if (event.address) {
        
        this.fetchCoordinates(event.address, (coords) => {
          console.log(`Adding Mapbox marker via Stimulus for event: ${event.name}`);
          
          // Create a custom marker element
          const el = document.createElement('div');
          el.className = 'marker';
          el.style.backgroundImage = `url(${event.photo_url || this.defaultPhotoUrlValue})`;
          el.style.width = '40px';
          el.style.height = '40px';
          el.style.backgroundSize = '100%';
          el.style.borderRadius = '50%';
          el.style.border = '2px solid white';
          el.style.boxShadow = '0 0 5px rgba(0,0,0,0.5)';
          el.style.cursor = 'pointer';
          



          // Add marker to map
          new mapboxgl.Marker(el)
            .setLngLat([coords.lng, coords.lat])
            .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(`<div style="background-color: rgba(0, 0, 0, 0.8); padding: 10px; border-radius: 5px;"><h5>${event.name}</h5><p>${event.address}</p></div>`))
            .addTo(this.map);
        });
      }
    })
  }

  fetchCoordinates(address, callback) {
    fetch(`/geocode_address?address=${encodeURIComponent(address)}`)
    .then(response => response.json())
    .then(data => {
      if (data.latitude && data.longitude) {
        callback({ lat: data.latitude, lng: data.longitude });
      } else {
        console.error('Geocoding failed:', data.error);
      }
    })
    .catch(error => console.error('Error fetching geocoding data:', error));
  }
}
