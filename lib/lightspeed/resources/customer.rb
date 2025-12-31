# frozen_string_literal: true

# Customers
# https://x-series-api.lightspeedhq.com/reference#customers-2

module Lightspeed
  class Customer < Resource
    include Lightspeed::ResourceActions.new uri: 'customers'

    def self.all_v0_9(params = {})
      get 'customers', params
    end
  end
end
