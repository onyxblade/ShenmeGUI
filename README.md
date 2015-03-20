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
  form(title: 'Your Application') do
    button('alert').onclick do
      alert 'Hello World!'
    end
    button('open an image').onclick do
      path = get_open_file_name
      @t.text = path
      @i.src = path
    end
    stack do
      label 'image path:'
      @t = textarea '', width: '100%'
    end
    @i = image "http://7jpqbr.com1.z0.glb.clouddn.com/bw-2014-06-19.jpg"
    @p = progress(75)
    button('+').onclick { @p.percent += 5 }
    button('-').onclick { @p.percent -= 5 }
  end
end

ShenmeGUI.start!
```

将会产生如图所示的界面：

![](http://cichol.qiniudn.com/shenmegui_example.png)


如未自动打开浏览器，可手动打开程序代码同目录的index.html。

button定义按钮，并通过onclick绑定上了点击事件。第一个按钮弹出一个对话框，第二个按钮弹出一个打开文件的对话框，将文件路径写到下方定义的textarea里，并改变image的src以显示这个图片。

下方的两个按钮演示了进度条的增减。

###系统需求

Ruby版本大于等于2.0.0。

因为前后端通讯使用了websocket，所以需要使用支持websocket的浏览器。

目前打开文件对话框只实现了windows版本，在Linux等使用会出错，以后会尝试在其他系统实现，除此之外对系统没有要求。

###wiki

了解更多请阅览[wiki](https://github.com/CicholGricenchos/ShenmeGUI/wiki)。