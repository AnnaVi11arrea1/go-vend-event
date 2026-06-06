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

    this.map.addControl(
      new mapboxgl.NavigationControl({ showCompass: false }),
      'top-right'
    )

    this.map.on('load', () => {
      this.addMarkers()
    })
  }

  async addMarkers() {
    const eventsWithAddress = this.eventsValue.filter((event) => event.address)
    if (eventsWithAddress.length === 0) return

    const geocodedEvents = await Promise.all(
      eventsWithAddress.map(async (event) => {
        const coords = await this.fetchCoordinates(event.address)
        if (!coords) return null
        return { event, coords }
      })
    )

    const validGeocodedEvents = geocodedEvents.filter(Boolean)
    if (validGeocodedEvents.length === 0) return

    const bounds = new mapboxgl.LngLatBounds()

    validGeocodedEvents.forEach(({ event, coords }) => {
      console.log(`Adding Mapbox marker via Stimulus for event: ${event.name}`)

      // Create a custom marker element
      const el = document.createElement('div')
      el.className = 'marker'
      el.style.backgroundImage = `url(${event.photo_url || this.defaultPhotoUrlValue})`
      el.style.width = '40px'
      el.style.height = '40px'
      el.style.backgroundSize = '100%'
      el.style.borderRadius = '50%'
      el.style.border = '2px solid white'
      el.style.boxShadow = '0 0 5px rgba(0,0,0,0.5)'
      el.style.cursor = 'pointer'

      // Add marker to map
      new mapboxgl.Marker(el)
        .setLngLat([coords.lng, coords.lat])
        .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(`<div style="background-color: rgba(0, 0, 0, 0.8); padding: 10px; border-radius: 5px;"><h5>${event.name}</h5><p>${event.address}</p></div>`))
        .addTo(this.map)

      bounds.extend([coords.lng, coords.lat])
    })

    if (validGeocodedEvents.length === 1) {
      const { lat, lng } = validGeocodedEvents[0].coords
      this.map.flyTo({ center: [lng, lat], zoom: 10 })
      return
    }

    this.map.fitBounds(bounds, {
      padding: 60,
      maxZoom: 11
    })
  }

  async fetchCoordinates(address) {
    try {
      const response = await fetch(`/geocode_address?address=${encodeURIComponent(address)}`)
      const data = await response.json()

      if (data.latitude && data.longitude) {
        return { lat: data.latitude, lng: data.longitude }
      }

      console.error('Geocoding failed:', data.error)
      return null
    } catch (error) {
      console.error('Error fetching geocoding data:', error)
      return null
    }
  }
}
