MM = require 'modestmaps'
Proj4js = require 'proj4js'
{WGS84, Proj, Point} = Proj4js
{PI, pow} = Math

class Proj4mm extends MM.Projection
  constructor: (zoom, transformation, crs, def, scales) ->
    if typeof zoom isnt 'number'
      {zoom, transformation, crs, def, scales} = zoom
    Proj4js.defs[crs] = def if def?
    @_proj = new Proj crs
    @_power = (zoom) ->  1/scales[zoom]
    MM.Projection.call @, zoom, transformation

  createCoordinate: (row, column, zoom) ->
    new MM.Coordinate row, column, zoom, @_power

  rawProject: (point) -> Proj4js.transform WGS84, @_proj, point

  rawUnproject: (point) -> Proj4js.transform @_proj, WGS84, point

  locationCoordinate: (location) ->
    point = @project new MM.Point location.lon, location.lat
    @createCoordinate point.y, point.x, @zoom

  coordinateLocation: (coordinate) ->
    coordinate = coordinate.zoomTo @zoom
    point = @unproject new MM.Point coordinate.column, coordinate.row
    new MM.Location point.y, point.x

#Proj4mm = (zoom, transformation, crs, def) ->
#  {zoom, transformation, crs, def} = zoom if typeof zoom isnt 'number'
#  Proj4js.defs[crs] = def if def?
#  @_proj = new Proj crs
#  MM.Projection.call @, zoom, transformation
#
#Proj4mm.prototype =
#  rawProject: (point) ->
#    {x, y} = Proj4js.transform WGS84, @_proj,
#      new Point 180.0 * point.x / PI, 180.0 * point.y / PI
#    new MM.Point x, y
#
#  rawUnproject: (point) ->
#    {x, y} = Proj4js.transform @_proj, WGS84, new Point point.x, point.y
#    new MM.Point PI * x / 180.0, PI * y / 180.0
#
#MM.extend Proj4mm, MM.Projection

module.exports = Proj4mm
