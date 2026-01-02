# frozen_string_literal: true

# Product Images

module Vend
  class ProductImage < Resource
    include Vend::ResourceActions.new uri: 'product_images'
  end
end
