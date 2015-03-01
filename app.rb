require 'erb'
require 'pp'
require 'em-websocket'
require 'json'

class ShenmeGUI
  class << self
    attr_accessor :elements
  end

  @elements = []

  def self.app(params={}, &block)
    el = Node.new(:body, params)
    el.instance_eval &block unless block.nil?
    File.open('index.html', 'w'){ |f| f.write el.render }
    el
  end

  class Node
    attr_accessor :id, :type, :prop, :children

    def inspect
      "##{@type}.#{@id} #{@prop}"
    end

    def initialize(type, params={})
      self.type = type
      self.prop = params
      self.id = ::ShenmeGUI.elements.size
      ::ShenmeGUI.elements << self
      self.children = []
    end

    def render(content=nil)
      template = ::ERB.new File.open("templates/#{type}.erb", 'r') { |f| f.read }
      template.result(binding)
    end
    
    %w{body stack flow button radio checkbox image select textline textarea}.each do |x|
      define_method "#{x}" do |value=nil, &block|
        params = {value: value}
        el = Node.new(x.to_sym, params)
        self.children << el
        el.instance_eval &block unless block.nil?
        el
      end
    end

    def render
      template = ::ERB.new File.open("templates/#{type}.erb", 'r') { |f| f.read }
      content = self.children.collect{|x| x.render}.join("\n")
      template.result(binding)
    end
  end

  def self.handle(msg)
    match_data = msg.match(/(.+?):(\d)(?:->)?({.+?})?/)
    command = match_data[1].to_sym
    id = match_data[2].to_i
    data = JSON.parse(match_data[3]) unless match_data[3].nil?
    case command
    when :click
      target = elements[id]
      p target
      $ws.send(target.inspect)
    when :change
      target = elements[id]
      data.each do |k,v|
        target.prop[k.to_sym] = v
      end
      p target
    end
  end

end

body = ShenmeGUI.app do
  button 'button1'

  stack do
    button 'button2'
    button 'button3'
    textarea 'default'
  end

  flow do 
    button 'ok'
    button 'ok'
    button 'ok'
    textline 'textline'
  end

end


EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 80) do |ws|
    ws.onopen { puts "WebSocket connection open" }

    ws.onclose { puts "Connection closed" }

    ws.onmessage do |msg|
      puts "Recieved message: #{msg}"
      ShenmeGUI.handle msg
    end
    
    $ws = ws
  end
end
