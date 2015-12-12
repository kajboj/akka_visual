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
        ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
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

  msg = [col, row, r, g, b].join(', ')

  EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
end

__END__
@@ index
<html>
<body>
<canvas id="tiles" width="512" height="512"></canvas>
</body>

<script type="text/javascript">
window.onload = function(){
  (function(){
    var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen    = function()  { console.log('websocket opened'); };
    ws.onclose   = function()  { console.log('websocket closed'); }
    ws.onmessage = function(m) { console.log('websocket message: ' +  m.data); };

    var c = document.getElementById("tiles");
    var ctx = c.getContext("2d");
    ctx.fillStyle = "#FF0000";
    ctx.fillRect(0,0,150,75);
  })();
}
</script>
</html>
