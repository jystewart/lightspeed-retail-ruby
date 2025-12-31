# frozen_string_literal: true

# Inventory
# https://docs.vendhq.com/reference#inventory

module Vend
  class Inventory < Resource
    include Vend::ResourceActions.new uri: 'inventory'
  end
end
