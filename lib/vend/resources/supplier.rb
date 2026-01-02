# frozen_string_literal: true

# Suppliers

module Vend
  class Supplier < Resource
    include Vend::ResourceActions.new uri: 'suppliers'
  end
end
