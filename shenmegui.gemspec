Gem::Specification.new do |s|
  s.name        = 'shenmegui'
  s.version     = '0.1'
  s.date        = '2015-03-11'
  s.summary     = "什么鬼!"
  s.description = "a simple HTML GUI for Ruby"
  s.authors     = ["CicholGricenchos"]
  s.email       = 'cichol@live.cn'
  s.files       = %w{lib lib/shenmegui static templates}.collect{|p| `ls #{p}`.split("\n").collect{|x| "#{p}/#{x}"}}.flatten
  s.homepage    = 'https://github.com/CicholGricenchos/shenmegui'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.0'
  s.add_runtime_dependency 'em-websocket'
end