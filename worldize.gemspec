Gem::Specification.new do |s|
  s.name     = 'worldize'
  s.version  = '0.0.1'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/worldize'

  s.summary = 'Simple coloured countries drawing'
  s.description = <<-EOF
    Worldize allows to draw world countries coloured on base of some
    numeric value for each country.
  EOF
  s.licenses = ['MIT']

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$/x
  end
  s.require_paths = ["lib"]
  s.bindir = 'bin'
  s.executables << 'worldize'

  s.add_dependency 'rmagick'
  s.add_dependency 'hashie'
  s.add_dependency 'color'

  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-its'
end
