module ShenmeGUI

  class Control
    attr_accessor :id, :properties, :events, :children, :parent

    def self.property(*arr)
      arr.each do |x|
        define_method(x) do
          @properties[x]
        end

        define_method("#{x}=") do |v|
          @properties[x] = v
          sync
        end
      end

      define_method(:initialize) do |x, params={}|
        params.merge!({arr[0] => x})
        super(params)
      end

    end

    available_events = %w{click input dblclick mouseover mouseout blur focus mousemove change}.collect(&:to_sym)
    available_events.each do |x|
      define_method("on#{x}") do |&block|
        return events[x] if block.nil?
        events[x] = lambda &block
        self
      end
    end

    def sync
      data = @properties
      msg = "sync:#{@id}->#{data.to_json}"
      ShenmeGUI.socket.send(msg)
    end

    def add_events
      data = @events.keys
      msg = "add_event:#{@id}->#{data.to_json}"
      ShenmeGUI.socket.send(msg)
    end

    def initialize(params={})
      @properties = params
      @id = ShenmeGUI.elements.size
      ShenmeGUI.elements << self
      @children = []
      @events = {}
    end

    def render(material = {})
      gem_path = $LOADED_FEATURES.grep(/.*\/lib\/shenmegui/)[0].match(/(.*)\/lib/)[1]
      template_path = gem_path + "/templates"
      type = self.class.name.match(/(?:.*::)(.+)/)[1]
      template = ::ERB.new File.read("#{template_path}/#{type}.erb")
      content = children.collect{|x| x.render}.join("\n")
      template.result(binding)
    end

  end

  class Body < Control
    def render
      gem_path = $LOADED_FEATURES.grep(/.*\/lib\/shenmegui/)[0].match(/(.*)\/lib/)[1]
      static_path = gem_path + "/static"
      style = %w{semantic-ui-custom style}.collect{|x| File.read("#{static_path}/#{x}.css")}.join("\n")
      script = File.read("#{static_path}/script.js")
      super({style: style, script: script})
    end

  end

  class Button < Control
    property :value

  end

  class Textline < Control
    property :value, :cursor

  end

  class Textarea < Control
    property :value, :cursor

  end

  class Stack < Control
  end

  class Flow < Control
  end

  class Image < Control
    property :src
  end

  class Checkbox < Control
    property :value, :checked

  end

  class Progress < Control
    property :value
  end

end
