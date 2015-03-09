require '../lib/shenmegui'

ShenmeGUI.app do
  @b = button(value:'button1')
  @b.onclick do
    @b.value = "clicked"
    @text.value = "ok"
  end

  @s = stack do 
    but = button(value:'change background')
    but.onclick do
      @s.style = "background-color: #ccc"
    end
    @text = textarea(value:'default')
    @text.onblur do
      this.value = "blur"
    end
    @text.onfocus do 
      this.value = "focus"
    end
  end

  @i = image src: "http://7jpqbr.com1.z0.glb.clouddn.com/bw-2014-06-19.jpg"
  @src = textline(value: @i.src)
  .onchange do
    @i.src = @src.value
  end

  label(value: 'test tring')

  @t = textline(value:'textline')
  @t.oninput do
    @b.value = this.value
  end

end

ShenmeGUI::Server.start!