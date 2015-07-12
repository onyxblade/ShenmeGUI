require '../lib/shenmegui'

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
    @i = image "http://s.amazeui.org/media/i/demos/bw-2014-06-19.jpg"
    @p = progress(75)
    button('+').onclick { @p.percent += 5 }
    button('-').onclick { @p.percent -= 5 }
  end
end

ShenmeGUI.open_browser
ShenmeGUI.start!