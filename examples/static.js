var fs = require('fs'),
    printlet = require('../lib/printlet'),
    tileJson = require('./osm.json');

printlet(tileJson)({
  width: 800,
  height: 600,
  zoom: 12,
  lng: 11.95,
  lat: 57.7,
  format: 'png',
  geojson: {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[11.95, 57.7], [12, 58]]
        },
        "properties": {
          "style": {
            "strokeStyle": "rgb(200, 0, 0, 0.6)",
            "lineWidth": "5"
          }
        }
      }
    ]
  }
}, function(err, data) {
  if (err != null) throw new Error(err + '\n' + err.stack);
  data.stream.pipe(fs.createWriteStream('image.png'));
});
