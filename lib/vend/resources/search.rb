# frozen_string_literal: true

# Search

module Vend
  class Search < Resource
    include Vend::ResourceActions.new uri: 'search'
  end
end
