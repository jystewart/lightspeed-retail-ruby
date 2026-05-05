# frozen_string_literal: true

# Outlet Product Taxes
# https://x-series-api.lightspeedhq.com/reference#outlet-product-taxes

module Lightspeed
  class OutletProductTax < Resource
    include Lightspeed::ResourceActions.new uri: 'outlet_taxes'

    read_scope  "taxes:read"
    write_scope "taxes:write"
  end
end
