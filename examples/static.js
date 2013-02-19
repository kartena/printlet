var fs = require('fs'),
    printlet = require('../lib/printlet'),
    tileJson = require('./osm.json');

printlet(tileJson)({
  width: 800,
  height: 600,
  zoom: 12,
  lng: 11.95,
  lat: 57.7
}, function(err, mime, stream) {
  var ws;
  if (err != null) throw new Error(err);
  ws = fs.createWriteStream('image.'+mime.split('/')[1]);
  stream.pipe(ws);
});
