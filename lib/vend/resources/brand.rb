# frozen_string_literal: true

# Brands

module Vend
  class Brand < Resource
    include Vend::ResourceActions.new uri: 'brands'
  end
end
