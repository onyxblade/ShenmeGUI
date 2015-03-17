require '../lib/shenmegui'

ShenmeGUI.app do
  form title: 'test' do
    button('open file').onclick { @text.text = ShenmeGUI::FileDialog.get_open_file_name; @i.src="file:///#{@text.text}" }
    @sel = select %w{1 2 3}

    radio %w{option1 option2 option3}, arrange: 'horizontal'

    radio %w{option7 option8 option9}, checked: 'option9'

    button('alert').onclick { alert 'test message'}

    @b = button 'button1'
    @b.onclick do
      @b.text = "clicked"
      @text << " ok"
      @t.text[0] = '1'
      @sel.options.pop
    end

    stack do 
      @text = textarea('default', width: '100%')
      @text.onblur do
        this.text = "blur"
      end
      @text.onfocus do 
        this.text = "focus"
      end
    end
    
    @i = image "http://7jpqbr.com1.z0.glb.clouddn.com/bw-2014-06-19.jpg"
    @src = textline @i.src
    @src.onchange do
      @i.src = @src.text
    end

    @t = textline 'textline'
    @t.oninput do
      @b.text = this.text
    end

    @pro = progress 15
    button('-').onclick{ @pro.percent -= 5}
    button('+').onclick{ @pro.percent += 5}

    checkbox ['check me', 'and me'], checked:['check me']

  end
end

ShenmeGUI.debug!

ShenmeGUI.start!
