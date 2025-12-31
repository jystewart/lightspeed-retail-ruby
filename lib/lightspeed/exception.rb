# frozen_string_literal: true

module Lightspeed
  class HttpError < StandardError
    attr_accessor :response_headers
    def initialize(headers)
      @response_headers = headers
    end
  end

  class BadRequest < HttpError; end
  class Unauthorized < HttpError; end
  class Forbidden < HttpError; end
  class NotFound < HttpError; end
  class MethodNotAllowed < HttpError; end
  class NotAccepted < HttpError; end
  class TimeOut < HttpError; end
  class ResourceConflict < HttpError; end
  class TooManyRequests < HttpError; end
  class InternalServerError < HttpError; end
  class BadGateway < HttpError; end
  class ServiceUnavailable < HttpError; end
  class GatewayTimeout < HttpError; end
  class BandwidthLimitExceeded < HttpError; end

  module HttpErrors
    ERRORS = {
      400 => Lightspeed::BadRequest,
      401 => Lightspeed::Unauthorized,
      403 => Lightspeed::Forbidden,
      404 => Lightspeed::NotFound,
      405 => Lightspeed::MethodNotAllowed,
      406 => Lightspeed::NotAccepted,
      408 => Lightspeed::TimeOut,
      409 => Lightspeed::ResourceConflict,
      429 => Lightspeed::TooManyRequests,
      500 => Lightspeed::InternalServerError,
      502 => Lightspeed::BadGateway,
      503 => Lightspeed::ServiceUnavailable,
      504 => Lightspeed::GatewayTimeout,
      509 => Lightspeed::BandwidthLimitExceeded
    }.freeze

    def throw_http_exception!(code, env)
      return unless ERRORS.keys.include? code
      response_headers = {}
      unless env.body.empty?
        response_headers = begin
          Oj.load(env.body, symbol_keys: true)
        rescue
          {}
        end
      end
      retry_after = env[:response_headers]&.[]('X-Retry-After')
      response_headers[:retry_after] = retry_after.to_i if retry_after
      raise ERRORS[code].new(response_headers), env.body
    end
  end
end
