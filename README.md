什么鬼！
======

###概述

ShenmeGUI是一套受[Shoes](http://shoesrb.com/)启发而诞生的GUI工具，拥有相似的DSL语法，使用HTML构建界面，并实现了前后端数据的双向绑定，可以便捷地实现一些轻量的GUI应用。

###安装

执行 `gem install shenmegui` 。

###示例代码

```ruby
require 'shenmegui'

ShenmeGUI.app do
  form(title: 'Main Form') do
    button('alert').onclick{ alert 'Hello World!' }
    button('open an image').onclick do
      path = get_open_file_name
      @t.text = path
      @i.src = path
    end
    stack do
      label 'image path:'
      @t = textarea 'http://s.amazeui.org/media/i/demos/bw-2014-06-19.jpg', width: '100%'
      @t.oninput{ @i.src = this.text }
    end
    @i = image @t.text
    @p = progress(75)
    button('+').onclick { @p.percent += 5 }
    button('-').onclick { @p.percent -= 5 }
  end

  form(title: 'Radiobox & Checkbox') do
    options = %w{option1 option2 option3}
    arr = []
    arr << select(options)
    arr << radio(options, arrange: 'horizontal')
    arr << checkbox(options, checked: options[1])
    arr.each{|x| x.onchange{ alert this.checked } }
  end

  form(title: 'Table') do
    @table = table([[1,2], [3,4]]).tap do |t|
      t.column_names = ['x', 'y']
      t.row_names_enum = (1..Float::INFINITY).to_enum
    end
    flow do
      @x = textline 'new x', width: '60px'
      @y = textline 'new y', width: '60px'
    end
    button('add row').onclick{ @table << [@x.text, @y.text]}
    button('remove row').onclick { @table.data.pop }
  end

end

ShenmeGUI.open_browser
ShenmeGUI.start!
```

将会产生如图所示的界面：

![](http://7mj4yb.com1.z0.glb.clouddn.com/ShenmeGUI_example20150713.png)

###系统需求

Ruby版本大于等于2.0.0。

因为前后端通讯使用了websocket，所以需要使用支持websocket的浏览器。

目前打开文件对话框只实现了windows版本，在Linux等系统使用会给出未实现的提示，除此之外对系统没有要求。

###wiki

了解更多请阅览[wiki](https://github.com/CicholGricenchos/ShenmeGUI/wiki)。