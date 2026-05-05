# frozen_string_literal: true

# Customers
# https://x-series-api.lightspeedhq.com/reference#customers-2

module Lightspeed
  class Customer < Resource
    include Lightspeed::ResourceActions.new uri: 'customers'

    read_scope  "customers:read"
    write_scope "customers:write"
    scope_required :all_v0_9, "customers:read"

    def self.all_v0_9(params = {})
      check_scope!(:all_v0_9)
      get 'customers', params
    end
  end
end
