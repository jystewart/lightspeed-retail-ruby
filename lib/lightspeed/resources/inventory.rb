# frozen_string_literal: true

# Inventory
# https://x-series-api.lightspeedhq.com/reference#inventory

module Lightspeed
  class Inventory < Resource
    include Lightspeed::ResourceActions.new uri: 'inventory'

    read_scope "inventory:read"
  end
end
