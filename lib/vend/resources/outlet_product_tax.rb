# frozen_string_literal: true

# Outlet Product Taxes

module Vend
  class OutletProductTax < Resource
    include Vend::ResourceActions.new uri: 'outlet_taxes'
  end
end
