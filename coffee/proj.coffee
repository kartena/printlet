Proj4js = require 'proj4js'
{WGS84, Proj} = Proj4js

crsCounter = 0

projection = (projection, transform, scale) ->
  if typeof projection isnt 'string'
    {projection, transform, scale, scales} = projection
  # Set default values if needed
  projection ?= '+proj=merc +a=1 +b=1 +lat_ts=0.0 +lon_0=0.0
 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs'
  transform ?= [0.5/Math.PI, 0.5, -0.5/Math.PI, 0.5]
  if transform instanceof Array
    transform = transformation.apply undefined, transform
  scale ?= if scales? then ((z) -> scales[z]) else ((z) -> Math.pow 2,z+8)
  # Create Proj4js projection object from proj4 definition
  # XXX: Proj4js API kinda sux
  defName = "CUSTOM_PROJECTION:#{crsCounter++}"
  Proj4js.defs[defName] = projection
  proj = new Proj defName
  delete Proj4js.defs[defName]

  project: (point, zoom) ->
    point = Proj4js.transform WGS84, proj, point
    point = transform.transform point
    @scale point, zoom

  unproject: (point, zoom) ->
    point = @scale point, undefined, zoom
    point = transform.untransform point
    Proj4js.transform proj, WGS84, point

  scale: (point, to, from) ->
    if from?
      p = scale from
      point = x:point.x / p, y:point.y / p
    if to?
      p = scale to
      point = x:point.x * p, y:point.y * p
    point


transformation = (a, b, c, d) ->
  transform: (p) ->
    x: a * p.x + b
    y: c * p.y + d

  untransform: (p) ->
    x: p.x - b / a
    y: p.y - d / c


tileUrl = (tmpl) ->
  (tile, zoom) ->
    tmpl
    .replace(/{Z}/i, zoom.toFixed 0)
    .replace(/{X}/i, tile.x.toFixed 0)
    .replace(/{Y}/i, tile.y.toFixed 0)

module.exports = {projection, transformation, tileUrl}
