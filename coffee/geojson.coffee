Promise = require 'promise'
util = require './util'

df = (v, dv) -> if v? then v else dv

module.exports = (opt) ->
  {ctx, lnglatPoint, geojson:{features}} = opt

  withStyle = (style, fn) ->
    fill = style?.fillStyle?
    stroke = style?.strokeStyle?
    stroke = yes if not stroke and not fill
    ctx.save()
    try
      (ctx[name] = value) for name, value of style
      fn(ctx, fill, stroke)
    finally
      ctx.restore()

  drawPath = (style, fn) ->
    withStyle style, (ctx, fill, stroke) ->
      ctx.beginPath()
      fn(ctx)
      ctx.fill() if fill
      ctx.stroke() if stroke

  drawFeature = (feature) ->
    new Promise (resolve, reject) ->
      {type, coordinates:lnglats} = feature.geometry
      {style} = feature.properties if feature.properties?
      switch type
        when 'Point'
          [x, y] = lnglatPoint lnglats

          if style?.marker?
            {image, text, radius, offset} = style.marker
            offset ?= fx:0.5, fy:0.5

          if image?
            util.img image, (err, img) ->
              if err?
                console.warn err
              else
                x -= img.width * df(offset.fx, 0) - df(offset.x, 0)
                y -= img.height * df(offset.fy, 0) - df(offset.y, 0)
                ctx.drawImage img, x, y, img.width, img.height
              resolve()
            return
          else if text?
            withStyle style, (ctx) ->
              {
                width
                actualBoundingBoxAscent: ascent
                actualBoundingBoxDescent: descent
              } = ctx.measureText text
              x -= width * df(offset.fx, 0) - df(offset.x, 0)
              y -= descent - ((ascent + descent) * df(offset.fy, 0)) - df(offset.y, 0)
              ctx.fillText text, x, y
          else
            drawPath style, (ctx) ->
              ctx.arc x, y, df(radius, 8), 0 , 2 * Math.PI, false
        when 'LineString'
          drawPath style, (ctx) ->
            ctx.lineTo.apply(ctx, lnglatPoint lnglat) for lnglat in lnglats
        when 'Polygon'
          drawPath style, (ctx) ->
            for ring in lnglats
              for lnglat in ring
                ctx.lineTo.apply(ctx, lnglatPoint lnglat)
              ctx.closePath()
        when 'MultiPolygon'
          drawPath style, (ctx) ->
            for polys in lnglats
              for ring in polys
                for lnglat in ring
                  ctx.lineTo.apply(ctx, lnglatPoint lnglat)
                ctx.closePath()
      resolve()

  features.reduce ((p, f) -> p.then drawFeature.bind(null, f)),
    new Promise((r) -> r())
