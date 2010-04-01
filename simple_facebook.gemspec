spec = Gem::Specification.new do |s|
  s.name = 'simple_facebook'
  s.version = '1.0'
  s.summary = "Simple interface for the Facebook API."
  s.description = %{Interface for the Facebook API.}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.require_path = 'lib'
  s.autorequire = 'simple_facebook'
  s.has_rdoc = false
  s.author = "Chris Vincent"
  s.email = "c.j.vincent@gmail.com"
  s.add_dependency('activesupport', '>= 2.2.2')
  s.add_dependency('json_pure', '>= 1.1.6')
end