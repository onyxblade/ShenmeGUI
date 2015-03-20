module ShenmeGUI

  @elements = []
  @temp_stack = []

  class << self
    attr_accessor :socket
    attr_reader :this, :elements

    def handle(msg)
      match_data = msg.match(/(.+?):(\d+)(?:->)?({.+?})?/)
      command = match_data[1].to_sym
      id = match_data[2].to_i
      target = @elements[id]
      data = JSON.parse(match_data[3]) if match_data[3]
      case command
        when :sync
          target.update(data)
        else
          event_lambda = target.events[command]
          @this = @elements[id]
          ShenmeGUI.instance_exec(&event_lambda) if event_lambda
          @this = nil

      end
      target
    end

    def app(params={}, &block)
      body(params, &block)
      File.open('index.html', 'w'){ |f| f.write @elements[0].render }
      nil
    end

    def alert(msg)
      data = {message: msg}
      @socket.send("alert:0->#{data.to_json}")
    end

    def get_open_file_name(params={})
      FileDialog.get_open_file_name(params)
    end

    def get_save_file_name(params={})
      FileDialog.get_save_file_name(params)
    end
    
    def enable_debug
      Thread.new do
        ShenmeGUI.instance_eval do
          bind = binding
          while true
            begin
              command = $stdin.gets.chomp
              result = bind.eval command
              puts "=> #{result}"
            rescue
              puts "#{$!}"
            end
          end
        end

      end
    end

    def start!
      ws_thread = Thread.new do
        EM.run do
          EM::WebSocket.run(:host => "0.0.0.0", :port => 80) do |ws|
            ws.onopen do
              puts "WebSocket connection open"
              @elements.each do |e|
                e.add_events
                e.sync
              end
            end

            ws.onclose { puts "Connection closed" }

            ws.onmessage do |msg|
              puts "Recieved message: #{msg}"
              handle msg
            end
            
            @socket = ws
          end
        end
      end

      #index_path = "#{Dir.pwd}/index.html"
      #`start file:///#{index_path}`

      ws_thread.join
    rescue Interrupt
      puts 'bye~'
    end

  end
end