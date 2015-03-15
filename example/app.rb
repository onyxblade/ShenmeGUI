require '../lib/shenmegui'

ShenmeGUI.app do
  body do
    button('open file').onclick { @text.text = ShenmeGUI::FileDialog.get_open_file_name }
    @sel = select %w{1 2 3}
    flow do
      radio %w{option1 option2 option3}
    end
    radio %w{option7 option8 option9}

    button('alert').onclick { alert 'test message'}

    @b = button 'button1'
    @b.onclick do
      @b.text = "clicked"
      @text << " ok"
      @t.text[0] = '1'
      @sel.options.pop
    end

    @s = stack do 
      @text = textarea('default')
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

    checkbox 'check me', checked: true

  end
end

ShenmeGUI.debug!

ShenmeGUI.start!
