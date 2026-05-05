# frozen_string_literal: true

# Brands
# https://x-series-api.lightspeedhq.com/reference#brands

module Lightspeed
  class Brand < Resource
    include Lightspeed::ResourceActions.new uri: 'brands'

    read_scope  "products:read"
    write_scope "products:write"
  end
end
