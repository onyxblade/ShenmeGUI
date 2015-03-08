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
      @text.value = "blur"
    end
    @text.onfocus do 
      @text.value = "focus"
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
    @b.value = @t.value
  end

end

ShenmeGUI::Server.start!