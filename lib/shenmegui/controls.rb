
module ShenmeGUI
  module Control

    class Base
      attr_accessor :id, :properties, :events, :children, :parent

      # 读取时直接从@properties读取，写入时则调用update_properties这个统一的接口
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

      # 注意@default_properties都是未上钩子的属性，因为钩子本身需要控件的self，而此时控件还未实例化
      def self.default(params)
        @default_properties ||= {}
        @default_properties.merge!(params)
      end

      def self.default_properties
        @default_properties
      end

      # 注册事件及获取事件的lambda，事件lambda存储在events属性里，最后的self是为了支持链式调用
      available_events = %w{click input dblclick mouseover mouseout blur focus mousedown mouseup change select}.collect(&:to_sym)
      available_events.each do |x|
        define_method("on#{x}") do |&block|
          return @events[x] if block.nil?
          @events[x] = lambda &block
          self
        end
      end

      def sync
        data = @properties
        before_sync
        msg = "sync:#{@id}->#{data.to_json}"
        ShenmeGUI.socket.send(msg)
      end

      def focus
        msg = "focus:#{@id}"
        ShenmeGUI.socket.send(msg)
      end

      def update_properties(data)
        data = Hash[data.keys.collect(&:to_sym).zip(data.values.collect{|x| add_hook(x)})]
        @properties.merge!(data)
      end

      def sync_events
        data = @events.keys
        #return if data.empty?
        msg = "add_event:#{@id}->#{data.to_json}"
        ShenmeGUI.socket.send(msg)
      end

      def initialize(params={})
        @properties = {}
        update_properties(self.class.default_properties.dup) if self.class.default_properties
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

      def before_sync
      end

      property :width, :height, :font, :margin

      private
        #这里存在重复给某字符串加钩子的情况，真是有够难抓的BUG
        def add_hook(obj)
          #p obj.class
          case obj
            when String
              HookedString.new(obj, self, :sync)
            when Array
              HookedArray.new(obj, self, :sync)
            when Hash
              HookedHash.new(obj, self, :sync)
            else
              obj
          end
        end
    end

    class Body < Base
      def render(material = {})
        gem_path = __FILE__.match(/(.*)\/lib/)[1]
        static_path = gem_path + "/static"
        style = "file:///#{static_path}/style.css"
        script = "file:///#{static_path}/script.js"
        super({style: style, script: script}.merge(material))
      end

    end

    class Form < Base
      property :title, :resizable
      default :width=>'400px'
    end

    class Button < Base
      property :text
      shortcut :text

    end

    class Textline < Base
      property :text, :selection
      shortcut :text
    end

    class Textarea < Base
      property :text, :selection
      shortcut :text
      default :width=>'250px', :height=>'60px'

      def <<(t)
        text << "\n#{t}"
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

      def before_sync
        @properties[:percent] = 0 if @properties[:percent] < 0
        @properties[:percent] = 100 if @properties[:percent] > 100
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
      #attr_accessor :row_names_enum
      property :data, :max_column_width, :column_names, :row_names, :row_names_enum, :column_names_enum, :editable
      shortcut :data
      default :width=>'100%', :height=>'150px'

      def before_sync
        row_names_enum = @properties[:row_names_enum]
        if row_names_enum
          @properties[:row_names] = []
          row_names_enum.rewind
          @properties[:data].size.times do
            @properties[:row_names] << row_names_enum.next
          end
        end
        column_names_enum = @properties[:column_names_enum]
        if column_names_enum
          @properties[:column_names] = []
          column_names_enum.rewind
          @properties[:data].max_by{|x| x.size}.size.times do
            @properties[:column_names] << column_names_enum.next
          end
        end
      end

      def << row
        data << row
      end
    end

    controls = constants.reject{|x| x==:Base}
    control_module = self
    controls.each do |x|
      ShenmeGUI.singleton_class.instance_eval do
        define_method "#{x}".downcase do |*arr, &block|
          el = control_module.const_get(x).new(*arr)
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
