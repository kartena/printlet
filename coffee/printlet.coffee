get = require 'get'
#MM = require 'modestmaps'
Canvas = require 'canvas'

drawGeoJSON = require './geojson'
{projection, tileUrl} = require './proj4mm'

module.exports = printlet = (tilejson) ->
  # TODO: read tilejson.crs and tilejson.projection to determen projection
  # use Google-y Mercator projection for now
  proj = projection tilejson
  tileSize = 256
  providerIndex = 0
  providers = (tileUrl tmpl for tmpl in tilejson.tiles)

  (opt, callback) ->
    {width, height, zoom, lng, lat, geojson} = opt
    #location = new MM.Location lat, lng
    location = x:lng, y:lat
    canvas = new Canvas width, height
    ctx = canvas.getContext '2d'

    centerCoordinate = proj.project location, zoom

    floor = (point) ->
      x: Math.floor point.x
      y: Math.floor point.y

    pointCoordinate = (point) ->
      # new point coordinate reflecting distance from map center, in tile widths
      x: (centerCoordinate.x + (point.x - width/2)) / tileSize
      y: (centerCoordinate.y + (point.y - height/2)) / tileSize

    coordinatePoint = (coord) ->
      # Return an x, y point on the map image for a given coordinate.
      #if coord.zoom isnt zoom
      #  coord = coord.zoomTo zoom
      x: (width / 2) + (tileSize * coord.x) - centerCoordinate.x
      y: (height / 2) + (tileSize * coord.y) - centerCoordinate.y

    locationPoint = (location) -> coordinatePoint proj.project location, zoom

    lnglatPoint = (lnglat) ->
      [lng, lat] = lnglat
      {x, y} = coordinatePoint proj.project {x:lng, y:lat}, zoom
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
      url = providers[providerIndex] c, zoom
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
            {x, y} = coordinatePoint c
            ctx.drawImage img, x, y, tileSize, tileSize
          completeRequests++
          checkDone()

    startCoord = floor pointCoordinate x:0, y:0
    endCoord = floor pointCoordinate x:width, y:height

    for column in [startCoord.x..endCoord.x]
      for row in [startCoord.y..endCoord.y]
        getTile x:column, y:row
    return
