
module ShenmeGUI
  module Control

    class Base
      attr_accessor :id, :properties, :events, :children, :parent

      def add_hook(obj)
        case obj
          when String
            HookedString.new(obj, self)
          when Array
            HookedArray.new(obj, self)
          when Hash
            HookedHash.new(obj, self)
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
            update_properties({x => v})
            sync
          end
        end
      end

      def self.shortcut(prop)
        define_method(:initialize) do |x=nil, params={}|
          params.merge!({prop => x})
          super(params)
        end

      end

      def self.default(params)
        @default_properties = params
      end

      def self.default_properties
        @default_properties
      end

      available_events = %w{click input dblclick mouseover mouseout blur focus mousedown mouseup change select}.collect(&:to_sym)
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

      def update_properties(data)
        data = Hash[data.keys.collect(&:to_sym).zip(data.values.collect{|x| add_hook(x)})]
        @properties.update(data)
      end

      def sync_events
        data = @events.keys
        msg = "add_event:#{@id}->#{data.to_json}"
        ShenmeGUI.socket.send(msg)
      end

      def initialize(params={})
        @properties = self.class.default_properties || {}
        update_properties(params)
        @id = ShenmeGUI.elements.size
        ShenmeGUI.elements << self
        @children = []
        @events = {}
      end

      def render(material = {})
        gem_path = __FILE__.match(/(.*)\/lib/)[1]
        template_path = gem_path + "/templates"
        type = self.class.name.match(/(?:.*::)(.+)/)[1].downcase
        template = ::ERB.new File.read("#{template_path}/#{type}.erb")
        content = children.collect{|x| x.render}.join("\n")
        template.result(binding)
      end

      def validate(params)
      end

      property :width, :height, :font, :background, :margin, :border

    end

    class Body < Base
      def render(material = {})
        gem_path = __FILE__.match(/(.*)\/lib/)[1]
        static_path = gem_path + "/static"
        style = %w{style}.collect{|x| File.read("#{static_path}/#{x}.css")}.join("\n")
        script = File.read("#{static_path}/script.js")
        super({style: style, script: script}.merge(material))
      end

    end

    class Form < Base
      property :title
      default :width=>'400px'
    end

    class Button < Base
      property :text
      shortcut :text

    end

    class Textline < Base
      property :text, :selection
      shortcut :text

      def text=(v)
        update_properties({text: v, selection: [v.size]*2 })
        sync
      end
    end

    class Textarea < Base
      property :text, :selection
      shortcut :text
      default :width=>'250px', :height=>'60px'

      def <<(t)
        text << "\n#{t}"
      end

      def text=(v)
        update_properties({text: v, selection: [v.size]*2 })
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
      default :width=>'100%'

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

    class Label < Base
      property :text
      shortcut :text
    end

    class Table < Base
      property :data
      shortcut :data
      default :width=>'100%', :height=>'150px'

      def << row
        data << row
      end
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
