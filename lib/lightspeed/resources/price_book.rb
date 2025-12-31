# frozen_string_literal: true

# PriceBooks
# https://x-series-api.lightspeedhq.com/reference#price-books

module Lightspeed
  class PriceBook < Resource
    include Lightspeed::ResourceActions.new uri: 'price_books'
  end
end
