# frozen_string_literal: true

# ProductTypes
# https://x-series-api.lightspeedhq.com/reference#product_types

module Lightspeed
  class ProductType < Resource
    include Lightspeed::ResourceActions.new uri: 'product_types'
  end
end
