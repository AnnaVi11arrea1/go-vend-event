// function initMap() {
//   // Set the map's center to a specific latitude and longitude
//   var mapCenter = { lat: 41.87657590074282, lng: -87.61936464305545 }; // Example: Chicago coordinates

//   // Create a new map instance and attach it to the div with the id "map"
//   var map = new google.maps.Map(document.getElementById('map'), {
//       zoom: 12, // Zoom level
//       center: mapCenter // Map center
//   });

//   // Example event data (could come from a Rails controller or JSON)
//   var events = [
//       { name: 'Coffee Shop A', latitude: 41.87657590074282, longitude: -87.61936464305545 },
//       { name: 'Coffee Shop B', latitude: 41.87857590074282, longitude: -87.61836464305545 }
//   ];

//   // Add markers for each event
//   events.forEach(function(event) {
//       var marker = new google.maps.Marker({
//           position: { lat: event.latitude, lng: event.longitude },
//           map: map,
//           title: event.name
//       });

//       // Optionally, add an info window to each marker
//       var infowindow = new google.maps.InfoWindow({
//           content: '<h3>' + event.name + '</h3>'
//       });

//       marker.addListener('click', function() {
//           infowindow.open(map, marker);
//       });
//   });
// }


// window.initMap = async function () {
//     const { Map } = await google.maps.importLibrary("maps");

//     const map = new Map(document.getElementById("map"), {
//       center: { lat: 41.87657590074282, lng: -87.61936464305545 },
//       zoom: 5,
//     });

//     const events = JSON.parse('<%= @events.to_json(only: [:latitude, :longitude, :name]) %>');

//     console.log("Loaded events data:", events); // Debugging: Check if events data is loaded

//     const markerImage = '<%= asset_path("bulb") %>';

//     events.forEach(event => {
//       if (event.latitude && event.longitude) {
//         console.log(`Adding marker for event: ${event.name} at (${event.latitude}, ${event.longitude})`); // Debugging: Verify marker data

//         new google.maps.Marker({
//           position: { lat: event.latitude, lng: event.longitude },
//           map: map,
//           icon: {
//             url: markerImage,
//             scaledSize: new google.maps.Size(32, 32), // Adjust as necessary
//           },
//           title: event.name,
//         });
//       }
//     });
//   };
//   console.log(markerImage);
