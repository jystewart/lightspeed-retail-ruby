# frozen_string_literal: true

module Lightspeed
  class Config < Hashie::Mash
    # Class variable to track if warnings have been shown
    @deprecation_warnings_shown = {}

    class << self
      attr_accessor :deprecation_warnings_shown
    end

    def initialize(hash = {}, &block)
      # Check for environment variables if not provided in hash
      check_env_variables if hash.empty? || (!hash.key?(:domain_prefix) && !hash.key?('domain_prefix'))
      super
    end

    def api_url
      "https://#{domain_prefix}.lightspeedhq.com/api"
    end

    private

    def check_env_variables
      # Check domain_prefix
      if ENV['LIGHTSPEED_DOMAIN_PREFIX']
        self.domain_prefix = ENV['LIGHTSPEED_DOMAIN_PREFIX']
      elsif ENV['VEND_DOMAIN_PREFIX']
        warn_deprecated_env('VEND_DOMAIN_PREFIX', 'LIGHTSPEED_DOMAIN_PREFIX')
        self.domain_prefix = ENV['VEND_DOMAIN_PREFIX']
      end

      # Check access_token
      if ENV['LIGHTSPEED_ACCESS_TOKEN']
        self.access_token = ENV['LIGHTSPEED_ACCESS_TOKEN']
      elsif ENV['VEND_ACCESS_TOKEN']
        warn_deprecated_env('VEND_ACCESS_TOKEN', 'LIGHTSPEED_ACCESS_TOKEN')
        self.access_token = ENV['VEND_ACCESS_TOKEN']
      end
    end

    def warn_deprecated_env(old_var, new_var)
      return if self.class.deprecation_warnings_shown[old_var]

      warn "[DEPRECATION] Using #{old_var} is deprecated. " \
           "Please use #{new_var} instead. " \
           "Support for #{old_var} will be removed in v1.0.0."

      self.class.deprecation_warnings_shown[old_var] = true
    end
  end
end
