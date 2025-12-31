# frozen_string_literal: true

require 'faraday/retry'

module Vend
  module Connection
    HEADERS = {
      'accept' => 'application/json'
    }.freeze

    def self.build(config)
      Faraday.new(url: config.api_url) do |conn|
        conn.options[:timeout] = 120
        conn.request config[:request_type] || :json
        conn.headers = HEADERS

        # Add retry logic for rate limits and transient failures
        conn.request :retry,
                     max: 3,
                     interval: 0.5,
                     interval_randomness: 0.5,
                     backoff_factor: 2,
                     retry_statuses: [429, 503],
                     exceptions: [Vend::TooManyRequests, Vend::ServiceUnavailable],
                     methods: %i[get post put delete],
                     retry_block: lambda { |env:, options:, retry_count:, exception:, will_retry_in:|
                       # Respect Retry-After header if present (from exception or response)
                       retry_after = if exception.respond_to?(:response_headers)
                                       exception.response_headers[:retry_after]
                                     elsif env.response_headers
                                       env.response_headers['Retry-After']
                                     end

                       if retry_after && retry_after.is_a?(Integer)
                         # retry_after is already in seconds
                         sleep(retry_after) if retry_after.positive? && retry_after < 60
                       elsif retry_after.is_a?(String)
                         retry_after_date = Time.httpdate(retry_after) rescue nil
                         if retry_after_date
                           sleep_time = [(retry_after_date - Time.now).to_f, 0].max
                           sleep(sleep_time) if sleep_time.positive? && sleep_time < 60
                         end
                       end
                     }

        conn.use Vend::Middleware::Auth, config
        conn.use Vend::Middleware::HttpException
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
