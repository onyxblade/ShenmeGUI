什么鬼！
======

###概述

ShenmeGUI是一套GUI工具，为Ruby程序构建图形界面。

程序将一些简单的界面描述DSL代码转为HTML，并绑定上相应的事件，使HTML的前端和Ruby后端可以同步数据。数据的双向绑定通过Websocket完成。

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

在事件内可以用this调用本控件的属性。

实例变量如@t在整个ShenmeGUI.app内是通用的，而局部变量只能在do...end块内通用，所以要在事件间共享变量的话，一定要使用实例变量，或者保证在同一个do...end内。

###控件

| 控件 | 定义方法 | 属性 | 备注 |
|--------|--------|--------|--------|
| 窗体 | form | title | title为窗体标题 |
| 按钮 | button(text) | text | text一般为控件相关的文本 |
| 文本标签 | label(text) | text | label的内容会加粗显示 |
| 单行文本框 | textline(text) | text |  |
| 文本域 | textarea(text) | text |  |
| 图片 | image(src) | src | src为图片地址 |
| 进度条 | progress(percent) | percent | percent为进度条百分比 |
| 单选框 | radio(options) | options, checked, arrange | options为一个包含选项的字符串数组，通过checked可获得当前选中选项的值，arrage为选项排列方式，有horizontal和vertical两种 |
| 复选框 | checkbox(text) | text, checked, arrange | 与radio类似，而checked是一个字符串数组 |
| 下拉多选框 | select(options) | options, checked | 与radio类似 |
| 堆叠层 | stack |  | 处于stack内的控件会堆叠显示，实质是display:block |
| 流动层 | flow |  | 处于flow内的控件会堆叠显示，实质是display:inline |

除了定义里传入的属性外，控件的其他属性可以通过hash参数传入。

控件的通用属性有width, height, font, background, margin, border，参照CSS缩写属性。

####通用方法

#####alert(msg)

弹出对话框，命令会直接转发到js的alert。

#####get_open_file_name/get_save_file_name

这两个是`ShenmeGUI::FileDialog`的模块方法，将弹出打开文件及保存文件的对话框，并返回选定的路径。

这两个方法是通过fiddle调用windows api实现的，所以暂时只支持windows环境。

####事件

暂时提供了以下事件，效果和HTML的事件是完全一致的，具体可以参考HTML的事件文档。

| 事件 |
|--------|
| click |
| input |
| dblclick |
| mouseover |
| mouseout |
| blur |
| focus |
| mousedown |
| mouseup |
| change |

事件的绑定方法是`"on#{event_name}"`。