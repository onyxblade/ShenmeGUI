require 'socket'

module ShenmeGUI

  @elements = []
  @temp_stack = []

  class FakeSocket
    attr_accessor :messages
    def initialize
      @messages = []
    end
    def send(msg)
      @messages << msg
    end
  end

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
          target.update_properties(data)
        else
          event_lambda = target.events[command]
          @this = @elements[id]
          ShenmeGUI.instance_exec(&event_lambda) if event_lambda
          @this = nil

      end
      target
    end

    def app(params={}, &block)
      @socket = FakeSocket.new
      body(params, &block)
      #找一个空闲的端口，不太好看
      temp_server = TCPServer.open('localhost', 0)
      @port = temp_server.addr[1]
      temp_server.close
      app_dir = File.expand_path($PROGRAM_NAME).match(/(.+)\/.+/)[1]
      File.open("#{app_dir}/index.html", 'w'){ |f| f.write @elements[0].render(port: @port) }
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

    def enable_debugging
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

    def open_browser
      app_dir = File.expand_path($PROGRAM_NAME).match(/(.+)\/.+/)[1]
      index_path = "#{app_dir}/index.html"
      if Gem.win_platform?
        `start file:///#{index_path}`
      elsif Gem.platforms[1].os == 'linux'
        `xdg-open file:///#{index_path}`
      end
    rescue
    end

    def start!
      ws_thread = Thread.new do
        EM.run do
          EM::WebSocket.run(:host => "0.0.0.0", :port => @port) do |ws|
            ws.onopen do
              puts "WebSocket connection open"
              @elements.each do |e|
                e.sync_events
                e.sync
              end
              @socket.messages.each do |msg|
                ws.send(msg)
              end
              @socket = ws
            end

            ws.onclose { puts "Connection closed" }

            ws.onmessage do |msg|
              puts "Recieved: #{msg}"
              handle msg
            end

            class << ws
              alias :original_send :send
              def send(msg)
                puts "Sent: #{msg}"
                original_send(msg)
              end
            end

            #@socket = ws
          end
        end
      end

      ws_thread.join
    rescue Interrupt
      puts 'bye~'
    end

  end
end
