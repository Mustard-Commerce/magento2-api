
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "magento2/api/version"

Gem::Specification.new do |spec|
  spec.name          = "magento2-api"
  spec.version       = Magento2::Api::VERSION
  spec.authors       = ["Gerold Böhler"]
  spec.email         = ["gerold.boehler@antiloop.com"]

  spec.summary       = %q{Magento 2 Rest Api Integration Wrapper}
  spec.description   = %q{Simple gem to easly access magento 2 rest api within ruby.}
  spec.homepage      = "https://www.antiloop.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'request_store'

  spec.add_runtime_dependency "curb"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
