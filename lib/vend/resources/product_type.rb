# frozen_string_literal: true

# ProductTypes

module Vend
  class ProductType < Resource
    include Vend::ResourceActions.new uri: 'product_types'
  end
end
