# frozen_string_literal: true

require 'hashie'
require 'oj'
require 'lightspeed/version'
require 'lightspeed/config'
require 'lightspeed/connection'
require 'lightspeed/exception'
require 'lightspeed/request'
require 'lightspeed/resource_actions'
require 'lightspeed/middleware/auth'
require 'lightspeed/middleware/http_exception'
require 'lightspeed/oauth2/auth_code'
require 'lightspeed/resources/resource'

module Lightspeed
  resources = File.join(File.dirname(__FILE__), 'lightspeed', 'resources', '**', '*.rb')
  Dir.glob(resources, &method(:require))

  class << self
    attr_reader :api, :config

    def configure
      @config = Lightspeed::Config.new.tap { |h| yield(h) }
      @api = Lightspeed::Connection.build(@config)
    end
  end
end
