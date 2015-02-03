var fs = require('fs'),
    printlet = require('../lib/printlet'),
    tileJson = require('./osm.json');

// Create a printlet instance from a TileJSON
printlet(tileJson)({
  // Specify the image options
  width: 800,
  height: 600,
  zoom: 12,
  lng: 11.95,
  lat: 57.7,
  format: 'png',
  // Add the features to be drawn
  geojson: {
    "type": "FeatureCollection",
    "features": [
      // Draw a semi-transparent line
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[11.95, 57.7], [12, 58]]
        },
        "properties": {
          "style": {
            "strokeStyle": "rgba(200, 0, 0, 0.6)",
            "lineWidth": "5"
          }
        }
      },
      // Draw a point represented by a text marker
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [11.95, 57.7]
        },
        "properties": {
          "style": {
            "font": "32px serif",
            "fillStyle": "rgb(20, 20, 120)",
            "marker": {
              "text": "Hello World"
            }
          }
        }
      }
    ]
  }
}, function(err, data) {
  if (err != null) throw new Error(err + '\n' + err.stack);
  // Get the image data as a stream and write save it to a file
  data.stream.pipe(fs.createWriteStream('image.png'));
});
