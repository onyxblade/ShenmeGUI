require 'erb'
require 'pp'

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
      "##{@type}.#{@id} #{@children}"
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
