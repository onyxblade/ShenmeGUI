require 'em-websocket'

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 80) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"
      ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"
      if msg == "click:3"
        ws.send "clicked 3"
      end
    }
  end
}