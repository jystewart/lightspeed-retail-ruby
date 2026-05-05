# frozen_string_literal: true

# Consignments
# https://x-series-api.lightspeedhq.com/reference#consignments-2

module Lightspeed
  class Consignment < Resource
    include Lightspeed::ResourceActions.new uri: 'consignments'

    read_scope  "consignments:read"
    write_scope %w[
      consignments:write:inventory_count
      consignments:write:stock_order
      consignments:write:stock_transfer
    ]
  end
end
