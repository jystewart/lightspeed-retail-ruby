# frozen_string_literal: true

# Product Images
# https://x-series-api.lightspeedhq.com/reference#product-images

module Lightspeed
  class ProductImage < Resource
    include Lightspeed::ResourceActions.new uri: 'product_images'

    read_scope  "products:read"
    write_scope "products:write"
  end
end
