require 'em-websocket'
require '../lib/shenmegui'

ShenmeGUI.app do
  @b = button 'button1'
  @b.onclick do
    @b.value = "clicked"
    @text.value = "ok"
  end

  @text = textarea 'default'

  @t = textline('textline')
  @t.oninput do
    @b.value = @t.value
  end

end

ShenmeGUI::Server.start!