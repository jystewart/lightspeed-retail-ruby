# frozen_string_literal: true

# PaymentTypes
# https://x-series-api.lightspeedhq.com/reference#payment-types

module Lightspeed
  class PaymentType < Resource
    include Lightspeed::ResourceActions.new uri: 'payment_types'
  end
end
