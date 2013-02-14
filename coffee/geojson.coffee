get = require 'get'
Canvas = require 'canvas'

module.exports = (opt, callback) ->
  {ctx, latlngPoint, geojson:{features}} = opt

  numRequests = 0
  completeRequests = 0
  processedFeatures = 0

  checkDone = ->
    if numRequests is completeRequests and processedFeatures is features.length
      callback()

  applyStyle = (styles) ->
    (ctx[style] = value) for style, value of styles
    fill: styles.fillStyle?
    stroke: styles.strokeStyle?

  drawFeature = (feature) ->
    {type, coordinates} = feature.geometry
    {style} = feature.properties
    drawPath = (fn) ->
      ctx.save()
      {fill, stroke} = applyStyle style if style?
      if fill and stroke
        ctx.beginPath()
        fn()
        ctx.fill() if fill
        ctx.stroke() if stroke
      ctx.restore()
    console.log type, style
    switch type
      when 'Point'
        [x, y] = latlngPoint coordinates
        if style?.image?
          console.log style.image
          {url, offset} = style.image
          numRequests++
          new get(url).asBuffer (err, data) ->
            (return console.warn err) if err?
            img = new Canvas.Image
            img.src = data
            offset ?= x:img.width/2, y:img.height/2
            x -= offset.x
            y -= offset.y
            ctx.drawImage img, Math.round(x), Math.round(y), img.width, img.height
            completeRequests++
            checkDone()
        else
          drawPath ->
            ctx.arc x, y, (style?.radius or 8), 0 , 2 * Math.PI, false
      when 'LineString', 'Polygon'
        drawPath ->
          ctx.lineTo.apply(ctx, latlngPoint coord) for coord in coordinates
          ctx.lineTo.apply(ctx, latlngPoint coordinates[0]) if type is 'Polygon'

  for feature in features
    drawFeature feature
    processedFeatures++
  checkDone()
  return
