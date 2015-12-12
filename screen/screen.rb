require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end

post '/' do
  col = params[:col]
  row = params[:row]
  r = params[:r]
  g = params[:g]
  b = params[:b]

  msg = [col, row, r, g, b].join(',')

  EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
end

__END__
@@ index
<html>
<body>
<canvas id="tiles" width="256" height="256"></canvas>
</body>

<script type="text/javascript">
window.onload = function(){
  (function(){
    function rgb(r, g, b) {
      return 'rgb(' + Math.round(r) + ',' + Math.round(g) + ',' + Math.round(b) + ')';
    }

    function toRgb(tile) {
      return rgb(tile[0], tile[1], tile[2]);
    }

    function limit(x) {
      if (x<0) {
        return 0;
      } else {
        if (x > 255) {
          return 255;
        } else {
          return x;
        }
      }
    }

    function fade(tile, speed) {
      return [
        limit(tile[0] - speed),
        limit(tile[1] - speed),
        limit(tile[2] - speed)
      ]
    }

    function square(ctx, i, j, size) {
      var x = i*tileSize;
      var y = j*tileSize;
      ctx.fillRect(x, y, x+size, y+size);
    }

    function createTiles(count, color) {
      var result = [];
      for(i=0; i<count; i++) {
        result[i] = [];
        for(j=0; j<count; j++) {
          result[i][j] = color;
        }
      };
      return result;
    }

    var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen    = function()  { console.log('websocket opened'); };
    ws.onclose   = function()  { console.log('websocket closed'); }

    var c = document.getElementById("tiles");
    var ctx = c.getContext("2d");

    var screenSize = parseInt(c.getAttribute("width"));
    var tileCount = 32;
    var tileSize = screenSize / tileCount;
    var fadeSpeed = 5;
    var fps = 20;

    var tiles = createTiles(tileCount, [255, 0, 255]);

    setInterval(function() {
      for(i=0; i<tileCount; i++) {
        for(j=0; j<tileCount; j++) {
          ctx.fillStyle = toRgb(tiles[i][j]);
          square(ctx, i, j, tileSize);
          tiles[i][j] = fade(tiles[i][j], fadeSpeed);
        }
      }
    }, 1000/20);

    ws.onmessage = function(m) {
      //console.log('websocket message: ' +  m.data);
      var tokens = m.data.split(',');
      var col = parseInt(tokens[0]);
      var row = parseInt(tokens[1]);
      var r   = parseInt(tokens[2]);
      var g   = parseInt(tokens[3]);
      var b   = parseInt(tokens[4]);
      tiles[col][row] = [r, g, b];
    };
  })();
}
</script>
</html>
