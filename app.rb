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

    def open
      tag = 
      case type
      when :app
        "<body>"
      when :block
        "<div>"
      when :inline
        "<span>"
      when :input
        "<input type=\"text\" />"
      end
      puts tag.nil? ? "<#{type}>" : tag
    end

    def close
      puts "</#{type}>"
    end
  end

  %w{app block inline button radio checkbox image select input textarea label}.each do |x|
    define_singleton_method "#{x}" do |params={}, &block|
      el = Element.new(x.to_sym)
      elements << el
      el.open
      instance_eval &block unless block.nil?
      el.close
    end
  end
end

ShenmeGUI.app do
  block do
   button
   button
   label
  end
  
  inline do 
    input
  end
end