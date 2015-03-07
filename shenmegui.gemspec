Gem::Specification.new do |s|
  s.name        = 'shenmegui'
  s.version     = '0.0.1'
  s.date        = '2015-03-07'
  s.summary     = "什么鬼!"
  s.description = "a simple HTML GUI for Ruby"
  s.authors     = ["CicholGricenchos"]
  s.email       = 'cichol@live.cn'
  s.files       = ["lib/shenmegui.rb","static/style.css","static/script.js"].concat(`ls templates`.split("\n").collect{|x| "templates/#{x}"})
  #s.homepage    = 'http://rubygems.org/gems/hola'
  #s.add_runtime_dependency 'em-websocket', '>0.0.0'
end