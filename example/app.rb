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
      @text.value = "mouseover"
    end
    @text.onfocus do 
      @text.value = "mouseout"
    end
  end

  @t = textline('textline')
  @t.oninput do
    @b.value = @t.value
  end

end

ShenmeGUI::Server.start!