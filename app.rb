require 'erb'
require 'pp'
require 'em-websocket'
require 'json'

def hook(bind)
  variables = bind.eval("local_variables")
  p variables
  variables.each do |x|
    ShenmeGUI.send(:define_singleton_method, x){ x = bind.eval("#{x}")}
  end
end

def hacked_instance_eval(&block)
  bind = nil
  called = false
  TracePoint.trace(:c_call, :line) do |tp|
    if called
      bind = tp.binding if tp.event == :line
      tp.disable
    else
      called = true if tp.event == :c_call
    end
  end
  result = instance_eval &block
  hook(bind)
  result
end

class ShenmeGUI
  class << self
    attr_accessor :elements, :socket, :temp_stack
  end

  @elements = []
  @temp_stack = []

  def self.app(params={}, &block)
    el = Node.new(:body, params)
    temp_stack << el 
    hacked_instance_eval &block unless block.nil?
    temp_stack.pop
    File.open('index.html', 'w'){ |f| f.write el.render }
    el
  end

  class Node
    attr_accessor :id, :type, :prop, :events, :children

    def inspect
      "##{@type}.#{@id} #{@prop}"
    end

    def initialize(type, params={})
      self.type = type
      self.prop = params
      self.id = ::ShenmeGUI.elements.size
      ::ShenmeGUI.elements << self
      self.children = []
      self.events = {}
    end

    def render
      template = ::ERB.new File.open("templates/#{type}.erb", 'r') { |f| f.read }
      content = self.children.collect{|x| x.render}.join("\n")
      template.result(binding)
    end
  end

  %w{body stack flow button radio checkbox image select textline textarea}.each do |x|
    define_singleton_method "#{x}" do |value=nil, &block|
      params = {value: value}
      el = Node.new(x.to_sym, params)
      temp_stack.last.children << el
      temp_stack << el
      hacked_instance_eval &block unless block.nil?
      temp_stack.pop
      el
    end
  end
  
  def self.handle(msg)
    match_data = msg.match(/(.+?):(\d+)(?:->)?({.+?})?/)
    command = match_data[1].to_sym
    id = match_data[2].to_i
    data = JSON.parse(match_data[3]) unless match_data[3].nil?
    case command
    when :click
      target = elements[id]
      p target
      event_lambda = elements[id].events[:click]
      ShenmeGUI.instance_exec(&event_lambda) if event_lambda 
    when :change
      target = elements[id]
      data.each do |k,v|
        target.prop[k.to_sym] = v
      end
      p target
    end
  end

end

ShenmeGUI.app do
  b = button 'button1'
  b.events[:click] = lambda {
    p but
  }

  stack do
    but = button 'button2'
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

lam = ShenmeGUI.elements[1].events[:click]
ShenmeGUI.instance_exec(&lam)

=begin
EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 80) do |ws|
    ws.onopen { puts "WebSocket connection open" }

    ws.onclose { puts "Connection closed" }

    ws.onmessage do |msg|
      puts "Recieved message: #{msg}"
      ShenmeGUI.handle msg
    end
    
    ShenmeGUI.socket = ws
  end
end
=end