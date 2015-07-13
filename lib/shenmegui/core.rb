require 'socket'

module ShenmeGUI

  @elements = []
  @temp_stack = []

  # FakeSocket把send的内容都记录下来，在WebSocket连接建立时会将这些消息读出，转发到ws上
  class FakeSocket
    attr_reader :messages
    def initialize
      @messages = []
    end
    def send(msg)
      @messages << msg
    end
  end

  class << self
    attr_reader :this, :elements, :socket

    def handle_message(msg)
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
    private :handle_message

    def app(params={}, &block)
      raise "ShenmeGUI app has been initialized" if @initialized
      @initialized = true
      @fake_socket = FakeSocket.new
      @socket = @fake_socket
      body(params, &block)
      #找一个空闲的端口，不太好看
      temp_server = TCPServer.open('localhost', 0)
      @port = temp_server.addr[1]
      temp_server.close
      @title = params[:title] || 'Application'
      app_dir = File.expand_path($PROGRAM_NAME).match(/(.+)\/.+/)[1]
      File.open("#{app_dir}/index.html", 'w'){ |f| f.write @elements[0].render(port: @port, title: @title) }
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
        `start #{index_path}`
      elsif Gem.platforms[1].os == 'linux'
        `xdg-open #{index_path}`
      elsif Gem.platforms[1].os == 'darwin'
        `open #{index_path}`
      end
    rescue
    end

    def start!
      EM.run do
        EM::WebSocket.run(:host => "0.0.0.0", :port => @port) do |ws|
          ws.onopen do
            puts "WebSocket connection open"
            # 同时只能有一个连接，而正常连接关闭的时候会把@socket指向FakeSocket，如果建立连接的时候发现@socket是WebSocket，便把连接关掉
            @socket.close if @socket.respond_to? :close
            @socket = ws

            class << ws
              alias :original_send :send
              def send(msg)
                puts "Sent: #{msg}"
                original_send(msg)
              end
            end

            @elements.each do |e|
              e.sync_events
              e.sync
            end
            @socket.send(@fake_socket.messages.shift) until @fake_socket.messages.empty?
          end

          ws.onclose do
            puts "Connection closed"
            @socket = @fake_socket
          end

          ws.onmessage do |msg|
            puts "Recieved: #{msg}"
            handle_message msg
          end

        end
      end
    rescue Interrupt
      puts 'bye~'
    end

  end
end
