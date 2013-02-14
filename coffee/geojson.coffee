module.exports = (ctx, latlngPoint, geojson) ->
  #lineStringToSvg = (coordinates, filter) ->
  #  filter ?= (x) -> x
  #  coordinates.reduce (p, c, i) ->
  #    p+(if i isnt 0 then ' L ' else ' ')+filter(c).join(' ')
  #  ,'M'

  applyStyle = (styles) ->
    (ctx[style] = value) for style, value of styles
    fill: styles.fillStyle?
    stroke: styles.strokeStyle?

  drawFeature = (feature) ->
    {type, coordinates} = feature.geometry
    ctx.save()
    {fill, stroke} = applyStyle feature.properties.style if feature.properties?
    (return) if not fill and not stroke
    switch type
      when 'LineString', 'Polygon'
        ctx.beginPath()
        ctx.lineTo.apply(ctx, latlngPoint coord) for coord in coordinates
        ctx.lineTo.apply(ctx, latlngPoint coordinates[0]) if type is 'Polygon'
        ctx.fill() if fill
        ctx.stroke() if stroke
    ctx.restore()

  for feature in geojson.features
    drawFeature feature
  return
