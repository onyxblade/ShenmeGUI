require 'erb'

class ShenmeGUI
  class << self
    attr_accessor :elements
  end

  @elements = []

  class Element
    attr_accessor :id, :type, :prop
    
    def initialize(type, params={})
      self.type = type
      self.prop = params
      self.id = ::ShenmeGUI.elements.size
    end

    def render(content=nil)
      template = ::ERB.new File.open("templates/#{type}.erb", 'r') { |f| f.read }
      template.result(binding)
    end
  end

  %w{body stack flow button radio checkbox image select textline textarea}.each do |x|
    define_singleton_method "#{x}" do |params={}, &block|
      el = Element.new(x.to_sym)
      elements << el
      $level += 1
      $stack << [el, $level]
      result = instance_eval &block unless block.nil?
      $level -= 1
      #el.render result
    end
  end
end

$stack = []
$level = 0

def render
  queue = []
  while $stack.size > 1
    p $stack
    cur = $stack.pop
    cur_level ||= cur[1]
    p [cur_level, cur[1]]
    if cur_level < cur[1]
      p 'next'
      queue << cur
      next
    end
    nex = $stack.pop
    if cur[1] > nex[1]
      cur[0] = cur[0].render if cur[0].class != String
      $stack << [nex[0].render(cur[0]), nex[1]]
    else
      cur[0] = cur[0].render if cur[0].class != String
      nex[0] = nex[0].render if nex[0].class != String
      $stack << [nex[0] + cur[0], nex[1]]
    end
    cur_level = nex[1]
    $stack.concat(queue) unless queue.empty?
  end
end


body = ShenmeGUI.body do
  #button {}

  stack do
    button
  end

  flow do 
    textline
  end
end

render
print $stack[0][0]

#print body
#File.open('index.html', 'w'){ |f| f.write body }