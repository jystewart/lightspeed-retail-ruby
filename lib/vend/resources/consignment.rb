# frozen_string_literal: true

# Consignments

module Vend
  class Consignment < Resource
    include Vend::ResourceActions.new uri: 'consignments'
  end
end
