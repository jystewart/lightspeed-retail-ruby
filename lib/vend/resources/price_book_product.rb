# frozen_string_literal: true

# PriceBookProducts

module Vend
  class PriceBookProduct < Resource
    include Vend::ResourceActions.new uri: 'price_book_products'
  end
end
