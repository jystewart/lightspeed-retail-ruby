# frozen_string_literal: true
# coding: utf-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightspeed/version'

Gem::Specification.new do |spec|
  spec.name = 'lightspeed-retail-ruby'
  spec.version = Lightspeed::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.0.0'
  spec.license = 'MIT'

  spec.authors       = ['Yurkiv Misha']
  spec.email         = ['m.yurkiv@coaxsoft.com']
  spec.summary       = 'Ruby client library for the Lightspeed Retail (X-Series) API'
  spec.description   = 'A modern Ruby client for the Lightspeed Retail (formerly Vend) X-Series API with automatic pagination, retry logic, and comprehensive resource coverage.'
  spec.homepage = 'https://github.com/coaxsoft/lightspeed-retail-ruby'

  spec.require_paths = ['lib']
  spec.files = Dir['README.md', 'CHANGELOG.md', 'MIGRATION.md', 'lib/**/*', '*.gemspec']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-nc'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'faraday', '~> 2.13'
  spec.add_dependency 'faraday-retry', '~> 2.2'
  spec.add_dependency 'hashie', '~> 5.0'
  spec.add_dependency 'jwt', '~> 3.1'
  spec.add_dependency 'oauth2'
  spec.add_dependency 'oj'

  spec.post_install_message = <<~MESSAGE

    ╔════════════════════════════════════════════════════════════════════════════╗
    ║                 Lightspeed Retail Ruby v#{Lightspeed::VERSION}                          ║
    ╠════════════════════════════════════════════════════════════════════════════╣
    ║                                                                            ║
    ║  This is the new home of vend-ruby-v2!                                     ║
    ║                                                                            ║
    ║  The gem has been renamed to reflect Lightspeed's acquisition of Vend.    ║
    ║  All functionality remains the same with full backward compatibility.     ║
    ║                                                                            ║
    ║  MIGRATION GUIDE:                                                          ║
    ║    1. Change: require 'vend' → require 'lightspeed'                        ║
    ║    2. Change: Vend.configure → Lightspeed.configure                        ║
    ║    3. Change: Vend::Product → Lightspeed::Product                          ║
    ║    4. Update ENV vars: VEND_* → LIGHTSPEED_*                               ║
    ║                                                                            ║
    ║  See MIGRATION.md for detailed migration instructions.                     ║
    ║                                                                            ║
    ║  Documentation: https://x-series-api.lightspeedhq.com/                     ║
    ║                                                                            ║
    ╚════════════════════════════════════════════════════════════════════════════╝

  MESSAGE
end
