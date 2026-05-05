# frozen_string_literal: true

# PriceBooks
# https://x-series-api.lightspeedhq.com/reference#price-books

module Lightspeed
  class PriceBook < Resource
    include Lightspeed::ResourceActions.new uri: 'price_books'

    read_scope  "products:read:price_books"
    write_scope "products:write:price_books"
  end
end
