# Printlet

Generate static map images from TileJSON configuration and draw stuff on top 
with GeoJSON.

Printlet supports an extended version of TileJSON for declaring custom map
projections. The specification resides
[here](https://github.com/perliedman/TileJSON/blob/master/2.0.0/README.md).

Intended for use as a library Printlet also comes with a thin HTTP API as an
example of implementation but also for practical use.

```javascript
render = printlet(require('./tile.json'));

render({
  width: 800,
  height: 600,
  zoom: 12,
  lng: 11.95,
  lat: 57.7
}, function (err, mime, stream) {});
```

## Getting started

### Installing dependencies on OS X using Homebrew

```
$ brew install cairo --without-x
```

*Note: This might cause some problems. Please report issues if Printlet wont
build after this step.*

### Installing dependencies on Ubuntu

```
$ sudo apt-get install libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++
```

### Installing Printlet using NPM

```
$ npm install -g printlet
```

### Running the HTTP server

```
$ printlet
```

Now point your browser to
[http://localhost:41462/800/600/12/11.95/57.7](http://localhost:41462/800/600/12/11.95/57.7)
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
