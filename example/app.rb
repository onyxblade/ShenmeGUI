require '../lib/shenmegui'

ShenmeGUI.app do
  @b = button 'button1'
  @b.onclick do
    @b.value = "clicked"
    @text.value = "ok"
  end
  @b.onmouseover do
    @text.value = "mouseover"
  end
  @b.onmouseout do 
    @text.value = "mouseout"
  end

  @text = textarea 'default'

  @t = textline('textline')
  @t.oninput do
    @b.value = @t.value
  end

end

ShenmeGUI::Server.start!