if typeof window isnt 'undefined'
  exports.canvas = (width, height) ->
    canvas = window.document.createElement('canvas')
    canvas.width = width
    canvas.height = height
    canvas

  exports.img = (url, callback) ->
    img = new Image
    img.onload = -> callback undefined, img
    img.src = url
else
  # Stop Browserify from including non-browser libs
  nonbrowser = {}
  nonbrowser[k] = require k for k in ['get', 'canvas']

  exports.canvas = (width, height) -> new nonbrowser.canvas width, height

  exports.img = (url, callback) ->
    new nonbrowser.get(url).asBuffer (err, data) ->
      return callback err if err
      img = new nonbrowser.canvas.Image
      img.src = data
      callback undefined, img
