什么鬼！
======

###概述

ShenmeGUI是一套GUI工具，为Ruby程序构建图形界面。

程序将一些简单的界面描述DSL代码转为HTML，并绑定上相应的事件，使HTML的前端和Ruby后端可以同步数据。前端的输入会即时同步到后端，而Ruby对控件属性的操作也能即时反映到前端。

数据的双向绑定通过Websocket完成。

###安装

运行 `gem install shenmegui` 或直接clone本代码库。

###示例代码

```ruby
require 'shenmegui'

ShenmeGUI.app do
  form(title: 'Your Application') do
    button('alert').onclick do
      alert 'Hello World!'
    end
    button('open an image').onclick do
      path = ShenmeGUI::FileDialog.get_open_file_name
      @t.text = path
      @i.src = "file:///#{path}"
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

实例变量如@t在整个ShenmeGUI.app内是通用的，而局部变量只能在do...end块内通用，所以要在事件间共享变量的话，一定要使用实例变量，或者保证在同一个do...end内。

###wiki

了解更多请阅览[wiki](https://github.com/CicholGricenchos/ShenmeGUI/wiki)。