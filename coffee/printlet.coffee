get = require 'get'
Canvas = require 'canvas'

drawGeoJSON = require './geojson'
{projection, tileUrl} = require './proj'

module.exports = printlet = (tilejson) ->
  proj = projection tilejson
  tileSize = 256
  providerIndex = 0
  providers = (tileUrl tmpl for tmpl in tilejson.tiles)

  (opt, callback) ->
    {width, height, zoom, lng, lat, geojson} = opt
    location = x:lng, y:lat
    canvas = new Canvas width, height
    ctx = canvas.getContext '2d'

    centerCoordinate = proj.project location, zoom

    pointCoordinate = (point) ->
      # Return projected map coordinate reflecting pixel points from map center
      x: centerCoordinate.x + (point.x - width/2)
      y: centerCoordinate.y + (point.y - height/2)

    coordinatePoint = (coord) ->
      # Return an x, y point on the map image for a given coordinate
      x: (width / 2) + (coord.x) - centerCoordinate.x
      y: (height / 2) + (coord.y) - centerCoordinate.y

    pointTile = (point) ->
      # Return tile coordinate reflecting pixel points from map center
      coord = pointCoordinate point
      x: coord.x / tileSize
      y: coord.y / tileSize

    tilePoint = (tile) ->
      # Return an x, y tile point for a given projected coordinate
      coordinatePoint x: tile.x * tileSize, y: tile.y * tileSize

    floor = (tile) ->
      x: Math.floor tile.x
      y: Math.floor tile.y

    lnglatPoint = (lnglat) ->
      [lng, lat] = lnglat
      {x, y} = coordinatePoint proj.project({x:lng, y:lat}, zoom)
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

    getTile = (tile, callback) ->
      # Cycle through tile providers to spread load
      url = providers[providerIndex] tile, zoom
      providerIndex = (providerIndex+1) % providers.length
      if url
        numRequests++
        console.log "Downloading: #{url}"
        new get(url).asBuffer (err, data) ->
          if err?
            console.log "#{url} error: #{err}"
          else
            img = new Canvas.Image
            img.src = data
            {x, y} = tilePoint tile
            ctx.drawImage img, x, y, tileSize, tileSize
          completeRequests++
          checkDone()

    startCoord = floor pointTile x:0, y:0
    endCoord = floor pointTile x:width, y:height

    for column in [startCoord.x..endCoord.x]
      for row in [startCoord.y..endCoord.y]
        getTile x:column, y:row
    return
