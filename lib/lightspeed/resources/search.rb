# frozen_string_literal: true

# Search
# https://x-series-api.lightspeedhq.com/reference#search

module Lightspeed
  class Search < Resource
    include Lightspeed::ResourceActions.new uri: 'search'
  end
end
