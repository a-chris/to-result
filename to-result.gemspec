# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'to-result'
  s.version     = '0.1.1'
  s.summary     = 'A wrapper over dry-monads to offer a handy and consistent way to implement the Railway pattern.'
  s.description = 'A wrapper over dry-monads to offer a handy and consistent way to implement the Railway pattern.'
  s.authors     = ['Christian Toscano']
  s.homepage    = 'https://github.com/a-chris/to-result'
  s.license     = 'MIT'

  s.require_paths = ['lib']
  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR).reject { |f| (f == '.gitignore') || f =~ /^examples/ }

  s.add_dependency 'dry-monads', '~> 1.5'
end
