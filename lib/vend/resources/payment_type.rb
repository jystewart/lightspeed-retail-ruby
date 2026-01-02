# frozen_string_literal: true

# PaymentTypes

module Vend
  class PaymentType < Resource
    include Vend::ResourceActions.new uri: 'payment_types'
  end
end
