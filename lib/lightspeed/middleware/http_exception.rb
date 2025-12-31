# frozen_string_literal: true

require 'faraday'
require 'lightspeed/exception'

module Lightspeed
  module Middleware
    class HttpException < Faraday::Middleware
      include Lightspeed::HttpErrors

      def on_complete(env)
        throw_http_exception! env[:status].to_i, env
        env
      end
    end
  end
end
