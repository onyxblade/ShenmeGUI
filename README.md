什么鬼！
======

###概述

ShenmeGUI是一套GUI工具，为Ruby程序构建图形界面。

程序将一些简单的界面描述DSL代码转为HTML，并绑定上相应的事件，使HTML的前端和Ruby后端可以同步数据，前端的输入将即时反映到Ruby变量的变化，Ruby对变量的设置也会即时反映到HTML的视图。数据的双向绑定是通过Websocket完成的。

###安装

运行 `gem install shenmegui` 或直接clone本代码库。

###示例代码

```ruby
require 'shenmegui'

ShenmeGUI.app do
  body do
    button('click me').onclick do
      @t.text = 'clicked'
      this.text = 'clicked'
    end
    @t = textline('text')
    @p = progress(75, text: 'progress')
    button('+').onclick { @p.percent += 5 }
    button('-').onclick { @p.percent -= 5 }
  end
end

ShenmeGUI.start!
```
如未自动打开浏览器，可手动打开程序代码同目录的index.html。

button和textline分别定义了一个button控件和一个textline控件，其中后者还被赋予实例变量@t。onclick给button绑定上了一个单击事件，在点击时改变两个控件的文本属性。

在事件内可以用this调用本控件的属性。

实例变量如@t在整个ShenmeGUI.app内是通用的，而局部变量只能在do...end块内通用，所以要在事件间共享变量的话，一定要使用实例变量，或者保证在同一个do...end内。

###控件

| 控件 | 定义方法 | 属性 | 备注 |
|--------|--------|--------|--------|
| 按钮 | button(text) | text | text一般为控件相关的文本 |
| 单行文本框 | textline(text) | text |  |
| 文本域 | textarea(text) | text |  |
| 图片 | image(src) | src | src为图片地址 |
| 进度条 | progress(percent) | percent, text | percent为进度条百分比 |
| 单选框 | radio(options) | options, checked | options为一个包含选项的字符串数组，通过checked可获得当前选中选项的值 |
| 复选框 | checkbox(text) | text, checked |  |
| 下拉多选框 | select(options) | options, checked | 与radio类似 |

除了第一个主要属性外，控件的其他属性可以通过hash参数传入，如示例里progress的用法。

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
| mousemove |
| change |

事件的绑定方法是`"on#{event_name}"`。