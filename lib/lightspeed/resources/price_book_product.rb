# frozen_string_literal: true

# PriceBookProducts
# https://x-series-api.lightspeedhq.com/reference#price-book-products

module Lightspeed
  class PriceBookProduct < Resource
    include Lightspeed::ResourceActions.new uri: 'price_book_products'

    read_scope  "products:read:price_books"
    write_scope "products:write:price_books"
  end
end
