get = require 'get'
MM = require 'modestmaps'
Canvas = require 'canvas'

module.exports = prinlet = (tilejson) ->
  providerIndex = 0
  providers = (new MM.Template tmpl for tmpl in tilejson.tiles)

  # TODO: read tilejson.crs and tilejson.projection to determen projection
  # use Google-y Mercator projection for now
  projection = new MM.MercatorProjection(0,
    MM.deriveTransformation(-Math.PI,  Math.PI, 0, 0,
                             Math.PI,  Math.PI, 1, 0,
                            -Math.PI, -Math.PI, 0, 1))
  tileSize = 256

  (opt, callback) ->
    {width, height, zoom, lng, lat} = opt
    location = new MM.Location lat, lng
    canvas = new Canvas width, height
    ctx = canvas.getContext '2d'

    centerCoordinate = projection.locationCoordinate(location).zoomTo zoom

    pointCoordinate = (point) ->
      # new point coordinate reflecting distance from map center, in tile widths
      coord = centerCoordinate.copy()
      coord.column += (point.x - width/2) / tileSize
      coord.row += (point.y - height/2) / tileSize
      coord

    coordinatePoint = (coord) ->
      # Return an x, y point on the map image for a given coordinate.
      if coord.zoom isnt zoom
        coord = coord.zoomTo zoom
      point = new MM.Point width/2, height/2
      point.x += tileSize * (coord.column - centerCoordinate.column)
      point.y += tileSize * (coord.row - centerCoordinate.row)
      point

    numRequests = 0
    completeRequests = 0

    checkDone = ->
      if completeRequests is numRequests
        callback undefined, 'image/png', canvas.pngStream()

    getTile = (c, callback) ->
      # Cycle through tile providers to spread load
      url = providers[providerIndex].getTile c
      providerIndex = (providerIndex+1) % providers.length
      if url
        numRequests++
        new get(url).asBuffer (err, data) ->
          (return callback "#{url} error: #{err}") if err?
          img = new Canvas.Image()
          img.src = data
          p = coordinatePoint c
          ctx.drawImage img, p.x, p.y, tileSize, tileSize
          completeRequests++
          checkDone()

    startCoord = pointCoordinate(new MM.Point 0, 0).container()
    endCoord = pointCoordinate(new MM.Point width, height).container()

    for column in [startCoord.column..endCoord.column]
      for row in [startCoord.row..endCoord.row]
        getTile new MM.Coordinate row, column, zoom
    return

if not module.parent
  fs = require 'fs'
  {parse} = require 'url'
  {createServer, STATUS_CODES} = require('http')
  [port, tileJSONPath] = process.argv[2..]

  render = prinlet JSON.parse fs.readFileSync(tileJSONPath or 'tile.json')
  server = createServer (req, res) ->
    [width, height, zoom, lat, lng] =
      parse(req.url).pathname.substr(1).split '/'
    opt =
      width: parseInt width
      height: parseInt height
      zoom: parseInt zoom
      lat: parseFloat lat
      lng: parseFloat lng
    render opt, (err, mime, stream) ->
      if err?
        res.writeHead 500
        res.end "#{STATUS_CODES[500]}: #{err}"
      else
        res.writeHead 200, 'Content-Type': mime
        stream.pipe res

  server.listen parseInt port or 4140
