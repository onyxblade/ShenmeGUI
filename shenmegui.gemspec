Gem::Specification.new do |s|
  s.name        = 'shenmegui'
  s.version     = '0.0.2'
  s.date        = '2015-03-07'
  s.summary     = "什么鬼!"
  s.description = "a simple HTML GUI for Ruby"
  s.authors     = ["CicholGricenchos"]
  s.email       = 'cichol@live.cn'
  s.files       = ["lib/shenmegui.rb","static/style.css","static/script.js"].concat(`ls templates`.split("\n").collect{|x| "templates/#{x}"})
  s.homepage    = 'https://github.com/CicholGricenchos/shenmegui'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.0'
  s.add_runtime_dependency 'em-websocket'
end