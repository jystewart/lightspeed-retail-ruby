# frozen_string_literal: true

# Customer Groups
# https://x-series-api.lightspeedhq.com/reference#customer-groups

module Lightspeed
  class CustomerGroup < Resource
    include Lightspeed::ResourceActions.new uri: 'customer_groups'
  end
end
