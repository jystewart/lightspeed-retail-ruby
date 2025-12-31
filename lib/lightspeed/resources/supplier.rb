# frozen_string_literal: true

# Suppliers
# https://x-series-api.lightspeedhq.com/reference#suppliers-2

module Lightspeed
  class Supplier < Resource
    include Lightspeed::ResourceActions.new uri: 'suppliers'
  end
end
