require '../lib/shenmegui'

ShenmeGUI.app do
  @b = button 'button1'
  @b.onclick do
    @b.value = "clicked"
    @text.value = "ok"
  end

  @s = stack do 
    but = button 'change background'
    but.onclick do
      @s.style = "background-color: #ccc"
    end
    @text = textarea 'default'
    @text.onblur do
      this.value = "blur"
    end
    @text.onfocus do 
      this.value = "focus"
    end
  end

  @i = image(nil, src: "http://7jpqbr.com1.z0.glb.clouddn.com/bw-2014-06-19.jpg")
  @src = textline(@i.src)
  .onchange do
    @i.src = @src.value
  end

  label('test tring')

  @t = textline('textline')
  @t.oninput do
    @b.value = this.value
  end

end

ShenmeGUI::Server.start!