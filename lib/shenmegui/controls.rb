
module ShenmeGUI
  module Control

    class Base
      attr_accessor :id, :properties, :events, :children, :parent

      def hook(obj)
        case obj
          when String
            HookedString.new(obj, self)
          when Array
            HookedArray.new(obj, self)
          else
            obj
        end
      end

      def self.property(*arr)
        arr.each do |x|
          define_method(x) do
            @properties[x]
          end

          define_method("#{x}=") do |v|
            v = hook v
            @properties[x] = v
            sync
          end
        end
      end

      def self.shortcut(prop)
        define_method(:initialize) do |x=nil, params={}|
          x = hook x
          params.merge!({prop => x})
          super(params)
        end

      end

      available_events = %w{click input dblclick mouseover mouseout blur focus mousemove mousedown mouseup change}.collect(&:to_sym)
      available_events.each do |x|
        define_method("on#{x}") do |&block|
          return events[x] if block.nil?
          events[x] = lambda &block
          self
        end
      end

      def sync
        data = @properties
        validate @properties
        msg = "sync:#{@id}->#{data.to_json}"
        ShenmeGUI.socket.send(msg)
      end

      def focus
        msg = "focus:#{@id}"
        ShenmeGUI.socket.send(msg)
      end

      def update(data)
        data = Hash[data.keys.collect(&:to_sym).zip(data.values.collect{|x| hook(x)})]
        @properties.update(data)
      end

      def add_events
        data = @events.keys
        msg = "add_event:#{@id}->#{data.to_json}"
        ShenmeGUI.socket.send(msg)
      end

      def initialize(params={})
        @properties = Hash[params.keys.collect(&:to_sym).zip(params.values.collect{|x| hook(x)})]
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

      def validate(params)
      end

      property :width, :height, :font, :background, :margin, :border

    end

    class Body < Base
      def render
        gem_path = $LOADED_FEATURES.grep(/.*\/lib\/shenmegui/)[0].match(/(.*)\/lib/)[1]
        static_path = gem_path + "/static"
        style = %w{style}.collect{|x| File.read("#{static_path}/#{x}.css")}.join("\n")
        script = File.read("#{static_path}/script.js")
        super({style: style, script: script})
      end

    end

    class Form < Base
      property :title
    end

    class Button < Base
      property :text, :state
      shortcut :text

    end

    class Textline < Base
      property :text, :cursor
      shortcut :text

    end

    class Textarea < Base
      property :text, :cursor
      shortcut :text

      def <<(t)
        text << "\n#{t}"
        sync
      end
    end

    class Stack < Base
    end

    class Flow < Base
    end

    class Image < Base
      property :src
      shortcut :src
    end

    class Checkbox < Base
      property :options, :checked, :arrange
      shortcut :options
    end

    class Progress < Base
      property :percent
      shortcut :percent

      def validate(params)
        params[:percent] = 0 if params[:percent] < 0
        params[:percent] = 100 if params[:percent] > 100
      end
    end

    class Radio < Base
      property :options, :checked, :arrange
      shortcut :options
    end

    class Select < Base
      property :options, :checked
      shortcut :options
    end

    controls = constants.reject{|x| x==:Base}
    controls.each do |x|
      ShenmeGUI.singleton_class.instance_eval do
        define_method "#{x}".downcase do |*arr, &block|
          el = const_get("ShenmeGUI::Control::#{x}").new(*arr)
          @temp_stack.last.children << el unless @temp_stack.empty?
          el.parent = @temp_stack.last unless @temp_stack.empty?
          @temp_stack << el
          instance_eval &block unless block.nil?
          @temp_stack.pop
          el
        end
        private "#{x}".downcase
      end
    end

  end
end
