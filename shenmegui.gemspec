Gem::Specification.new do |s|
  s.name        = 'shenmegui'
  s.version     = '0.3.3'
  s.date        = '2015-03-20'
  s.summary     = "什么鬼!"
  s.description = "a simple HTML GUI for Ruby"
  s.authors     = ["CicholGricenchos"]
  s.email       = 'cichol@live.cn'
  s.files       = %w{lib lib/shenmegui templates}.collect{|p| `ls #{p}`.split("\n").collect{|x| "#{p}/#{x}"}}.flatten.concat(['static/style.css', 'static/script.js'])
  s.homepage    = 'https://github.com/CicholGricenchos/shenmegui'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.0'
  s.add_runtime_dependency 'em-websocket'
end