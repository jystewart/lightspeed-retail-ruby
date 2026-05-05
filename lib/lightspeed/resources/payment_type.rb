# frozen_string_literal: true

# PaymentTypes
# https://x-series-api.lightspeedhq.com/reference#payment-types

module Lightspeed
  class PaymentType < Resource
    include Lightspeed::ResourceActions.new uri: 'payment_types'

    read_scope "payment_types:read"
  end
end
