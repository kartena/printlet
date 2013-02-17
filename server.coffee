fs = require 'fs'
{parse} = require 'url'
{createServer, STATUS_CODES} = require('http')

printlet = require './lib/printlet'

[port, tileJSONPath] = process.argv[2..]

render = printlet JSON.parse fs.readFileSync(tileJSONPath or 'tile.json')

server = createServer (req, res) ->
  {pathname, query} = parse req.url, true
  [width, height, zoom, lat, lng] = pathname.substr(1).split '/'
  if width and height and zoom? and lat? and lng?
    opt =
      width: parseInt width
      height: parseInt height
      zoom: parseInt zoom
      lat: parseFloat lat
      lng: parseFloat lng
    (opt.geojson = JSON.parse query.geojson) if query.geojson?
    render opt, (err, mime, stream) ->
      if err?
        res.writeHead 500
        res.end "#{STATUS_CODES[500]}: #{err}"
      else
        res.writeHead 200, 'Content-Type': mime
        stream.pipe res

server.listen parseInt port or 4140
