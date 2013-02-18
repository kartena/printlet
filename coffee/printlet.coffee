get = require 'get'
MM = require 'modestmaps'
Canvas = require 'canvas'

drawGeoJSON = require './geojson'
Proj4mm = require './proj4mm'

module.exports = printlet = (tilejson) ->
  # TODO: read tilejson.crs and tilejson.projection to determen projection
  # use Google-y Mercator projection for now
  if tilejson.crs and tilejson.projection
    {crs, transform:[ta, tc, te, tf], projection:def, scales} = tilejson
    projection = new Proj4mm
      zoom: 0
      transformation: new MM.Transformation ta, 0, tc, 0, te, tf
      crs: crs
      def: def
      scales: scales
  else
    projection = new MM.MercatorProjection(0,
      MM.deriveTransformation(-Math.PI,  Math.PI, 0, 0,
                               Math.PI,  Math.PI, 1, 0,
                              -Math.PI, -Math.PI, 0, 1))
  tileSize = 256
  providerIndex = 0
  providers = for tmpl in tilejson.tiles
    provider = new MM.Template tmpl
    provider.tileLimits = [
      projection.createCoordinate(-1e10,-1e10,0).zoomTo(tilejson.minzoom or 0),
      projection.createCoordinate(1e10,1e10,0).zoomTo(tilejson.maxzoom or 18)
    ]
    provider

  (opt, callback) ->
    {width, height, zoom, lng, lat, geojson} = opt
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

    locationPoint = (location) ->
      coordinatePoint projection.locationCoordinate(location).zoomTo zoom

    lnglatPoint = (lnglat) ->
      [lng, lat] = lnglat
      loc = new MM.Location lat, lng
      {x, y} = coordinatePoint projection.locationCoordinate(loc).zoomTo zoom
      [x, y]

    numRequests = 0
    completeRequests = 0

    checkDone = ->
      if completeRequests is numRequests
        doCallback = -> callback undefined, 'image/png', canvas.pngStream()
        if geojson?
          drawGeoJSON {ctx, lnglatPoint, geojson}, doCallback
        else
          doCallback()

    getTile = (c, callback) ->
      # Cycle through tile providers to spread load
      url = providers[providerIndex].getTile c
      providerIndex = (providerIndex+1) % providers.length
      if url
        numRequests++
        new get(url).asBuffer (err, data) ->
          (return callback "#{url} error: #{err}") if err?
          img = new Canvas.Image
          img.src = data
          {x, y} = coordinatePoint c
          ctx.drawImage img, x, y, tileSize, tileSize
          completeRequests++
          checkDone()

    startCoord = pointCoordinate(new MM.Point 0, 0).container()
    endCoord = pointCoordinate(new MM.Point width, height).container()

    for column in [startCoord.column..endCoord.column]
      for row in [startCoord.row..endCoord.row]
        getTile projection.createCoordinate row, column, zoom
    return
