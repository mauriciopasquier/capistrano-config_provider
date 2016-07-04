lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/config_provider/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-config_provider'
  spec.version       = Capistrano::ConfigProvider::VERSION
  spec.authors       = ['Mauricio Pasquier Juan']
  spec.email         = ['<mauricio@pasquierjuan.com.ar>']

  spec.summary       = %q{Provision your app config from outside your repository.}
  spec.description   = %q{Capistrano tasks for provisioning app configuration from
                          a git repository or a local path, mirroring linked
                          files/dirs structure.}
  spec.homepage      = 'https://github.com/mauriciopasquier/capistrano-config_provider.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
end
