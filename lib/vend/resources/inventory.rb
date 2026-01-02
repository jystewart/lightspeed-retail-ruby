# frozen_string_literal: true

# Inventory

module Vend
  class Inventory < Resource
    include Vend::ResourceActions.new uri: 'inventory'
  end
end
