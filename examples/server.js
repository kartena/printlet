var fs = require('fs'),
    parse = require('url').parse,
    http = require('http'),
    createServer = http.createServer,
    STATUS_CODES = http.STATUS_CODES,
    printlet = require('../lib/printlet'),

    args = process.argv.slice(2),
    port = parseInt(args[0] || 41462),
    tileJson = require(
      (args[1] != null) ? process.cwd()+'/'+args[1] : './osm.json'
    ),

    render = printlet(tileJson),
    server;

server = createServer(function(req, res) {
  var url = parse(req.url, true),
      pathname = url.pathname,
      query = url.query,
      params = pathname.substr(1).split('/'),
      width = params[0],
      height = params[1],
      zoom = params[2],
      lng = params[3],
      lat = params[4];
  if (width && height && zoom != null && lat != null && lng != null) {
    opt = {
      width: parseInt(width),
      height: parseInt(height),
      zoom: parseInt(zoom),
      lat: parseFloat(lat),
      lng: parseFloat(lng)
    };
    if (query.geojson != null) {
      opt.geojson = JSON.parse(query.geojson);
    }
    return render(opt, function(err, mime, stream) {
      if (err != null) {
        res.writeHead(500);
        res.end(STATUS_CODES[500] + ": " + err);
      } else {
        res.writeHead(200, {
          'Content-Type': mime
        });
        stream.pipe(res);
      }
    });
  }
});

server.listen(port);
