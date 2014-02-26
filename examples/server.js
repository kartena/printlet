#!/usr/bin/env node

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
  try {
    var url = parse(req.url, true),
        pathname = url.pathname,
        query = url.query,
        params = pathname.substr(1).split('/'),
        zoom = parseInt(params[0]),
        lng = parseFloat(params[1]),
        lat = parseFloat(params[2]),
        dimensions = params[3].split('x'),
        end = dimensions[1].split('.'),
        width = parseInt(dimensions[0]),
        height = parseInt(end[0]),
        format = end[1];
    opt = {
      width: width,
      height: height,
      zoom: zoom,
      lat: lat,
      lng: lng,
      format: format
    };
    if (query.geojson != null) {
      opt.geojson = JSON.parse(query.geojson);
    }
    render(opt, function(err, data) {
      if (err != null) {
        res.writeHead(500);
        res.end(STATUS_CODES[500] + ": " + err);
      } else {
        res.writeHead(200, {
          'Content-Type': 'image/'+format
        });
        data.stream.pipe(res);
      }
    });
  } catch (err) {
    res.writeHead(500);
    res.end(STATUS_CODES[500] + ": " + err);
  }
});

server.listen(port);
