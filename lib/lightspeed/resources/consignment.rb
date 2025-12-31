# frozen_string_literal: true

# Consignments
# https://x-series-api.lightspeedhq.com/reference#consignments-2

module Lightspeed
  class Consignment < Resource
    include Lightspeed::ResourceActions.new uri: 'consignments'
  end
end
