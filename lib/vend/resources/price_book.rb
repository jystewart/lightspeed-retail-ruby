# frozen_string_literal: true

# PriceBooks

module Vend
  class PriceBook < Resource
    include Vend::ResourceActions.new uri: 'price_books'
  end
end
