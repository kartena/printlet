get = require 'get'
Canvas = require 'canvas'

queue = (ls, fn) ->
  if ls.length
    fn ls.shift(), -> queue ls, fn
  else
    fn()

df = (v, dv) -> if v? then v else dv

module.exports = (opt, callback) ->
  {ctx, lnglatPoint, geojson:{features}} = opt

  withStyle = (style, fn) ->
    fill = style?.fillStyle?
    stroke = style?.strokeStyle?
    stroke = yes if not stroke and not fill
    ctx.save()
    try
      (ctx[name] = value) for name, value of style
      fn(ctx)
    finally
      ctx.restore()

  drawPath = (style, fn) ->
    withStyle style, (ctx) ->
      ctx.beginPath()
      fn(ctx)
      ctx.fill() if fill
      ctx.stroke() if stroke

  drawFeature = (feature, callback) ->
    {type, coordinates:lnglats} = feature.geometry
    {style} = feature.properties if feature.properties?
    switch type
      when 'Point'
        [x, y] = lnglatPoint lnglats

        drawText = =>
          if style?.text?
            text = style.text
            offset = text.offset
            if offset? then text = text.text else offset = fx:0.5, fy:0.5
            withStyle style, (ctx) ->
              {
                width
                actualBoundingBoxAscent: ascent
                actualBoundingBoxDescent: descent
              } = ctx.measureText text
              x -= width * df(offset.fx, 0) - df(offset.x, 0)
              y -= descent - ((ascent + descent) * df(offset.fy, 0)) - df(offset.y, 0)
              ctx.fillText text, x, y
            true
          false

        if style?.image?
          url = style.image
          offset = url.offset
          if offset? then url = url.url else offset = fx:0.5, fy:0.5
          new get(url).asBuffer (err, data) ->
            (return console.warn err) if err?
            img = new Canvas.Image
            img.src = data
            x -= img.width * df(offset.fx, 0) - df(offset.x, 0)
            y -= img.height * df(offset.fy, 0) - df(offset.y, 0)
            ctx.drawImage img, x, y, img.width, img.height
            drawText()
            callback()
          return
        else if not drawText()
          drawPath style, (ctx) ->
            ctx.arc x, y, (style?.radius or 8), 0 , 2 * Math.PI, false
      when 'LineString', 'Polygon'
        drawPath style, (ctx) ->
          ctx.lineTo.apply(ctx, lnglatPoint lnglat) for lnglat in lnglats
          ctx.lineTo.apply(ctx, lnglatPoint lnglats[0]) if type is 'Polygon'
    callback()

  queue features.slice(), (feature, next) ->
    if next
      drawFeature feature, next
    else
      callback()

  return
