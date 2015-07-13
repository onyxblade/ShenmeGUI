require '../lib/shenmegui'

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