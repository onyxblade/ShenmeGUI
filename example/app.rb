require '../lib/shenmegui'

ShenmeGUI.app do
  body do

    @b = button 'button1'
    @b.onclick do
      @b.text = "clicked"
      @text.text = "ok"
    end

    @s = stack do 
      but = button 'change background'
      but.onclick do
        @s.background = "#ccc"
      end
      @text = textarea('default', width: '100px')
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
  end
end

ShenmeGUI.start!