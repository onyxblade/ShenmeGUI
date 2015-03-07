require 'em-websocket'
require '../lib/shenmegui'

ShenmeGUI.app do
  @b = button 'button1'
  @b.onclick do
    @b.value = "clicked"
    @t.value = "ok"
  end

  stack do
    @but = button 'button2'
    button 'button3'
    @t = textarea 'default'
  end

  flow do 
    button 'ok'
    button 'ok'
    button 'ok'
    @text = textline('textline')
    @text.oninput do
      @b.value = @text.value
    end
  end

end

ShenmeGUI::Server.start!