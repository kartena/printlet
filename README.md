# Printlet

Generate static map images from TileJSON configuration and draw stuff on top
with GeoJSON.

Printlet supports an extended version of TileJSON for declaring custom map
projections. The specification resides
[here](https://github.com/perliedman/TileJSON/blob/master/2.0.0/README.md).

Intended for use as a library Printlet also comes with a thin HTTP API as an
example of implementation but also for practical use.

```javascript
var printlet = require('printlet'),
    render = printlet(require('./tile.json'));

render({
  width: 800,
  height: 600,
  zoom: 12,
  lng: 11.95,
  lat: 57.7,
  format: 'png'
}, function (err, data) { data.stream.pipe(process.stdout); });
```

## Getting started

### Installing dependencies on OS X using Homebrew

```
$ brew install cairo --without-x
```

*Note: This might cause some problems. Please report issues if Printlet wont
build after this step.*

#### Troubleshooting problems with libpng (on OS X 10.7.5):
```
# For freetype
export LIBPNG_CFLAGS=`/usr/local/opt/libpng/bin/libpng-config --cflags`
export LIBPNG_LDFLAGS=`/usr/local/opt/libpng/bin/libpng-config --ldflags`

# For cairo
brew link libpng --force
brew install --env=std cairo --without-x
brew link cairo --force
brew link pixman --force
brew link freetype --force
```


### Installing dependencies on Ubuntu

```
$ sudo apt-get install libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++
```

### Installing dependencies on Fedora

```
$ sudo yum --enablerepo=updates-testing install npm cairo-devel
```
*Drop "--enablerepo=updates-testing" if you're on F19 or greater.*

### Installing Printlet using NPM

```
$ npm install -g printlet
```

### Running the HTTP server

```
$ printlet
```

Now point your browser to
[http://localhost:41462/12/11.95/57.7/800x600.png](http://localhost:41462/12/11.95/57.7/800x600.png)
and get a nice view of Göteborg using a default OSM TileJSON.

### With custom TileJSON

Grab your favorite TileJSON and point Printlet to it. There is an example
TileJSON with a custom projection to try out
[here](https://github.com/kartena/printlet/blob/master/examples/lmv.json).

```
$ printlet 41462 your/tile.json
```

Open browser to same URL as previous step to check it out.

### Building Printlet for developers

```
$ git clone https://github.com/kartena/printlet.git
$ cd printlet
$ npm install
```

## Examples of using Printlet as a lib

There is a minimalistic [map image
generator](https://github.com/kartena/printlet/blob/master/examples/static.js)
in the examples folder to get the basic gist of the Printlet lib.

Also there is a more advanced implementation using the GeoJSON drawing
capabilities as a [HTTP
server](https://github.com/kartena/printlet/blob/master/examples/server.js).

## Drawing GeoJSON features

At the moment styles for GeoJSON is defined in the `properties` attribute of
a GeoJSON feature as a dictionary called `style`. The keys under `style`
are the same as the HTML5 canvas API for styling shapes.

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [11.95, 57.7]
      },
      "properties": {
        "style": {
          "fillStyle": "rgba(200, 0, 0, 0.6)",
          "marker": {
            "radius": 15
          }
        }
      }
    }
  ]
}
```

Exceptions to the canvas properties is `marker` which is possible to define for
geometry type `Point` and describes how points are drawn with images, text or a
circle.

```json
{
  "image": "http://example.org/image.png",
  "text": "Example text...",
  "radius": 5,
  "offset": {
    "x": 10,
    "y": -15,
    "fx": 0.5,
    "fy": 0.5
  }
}
```
