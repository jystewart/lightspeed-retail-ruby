# frozen_string_literal: true

# Customers

module Vend
  class Customer < Resource
    include Vend::ResourceActions.new uri: 'customers'

    def self.all_v0_9(params = {})
      get 'customers', params
    end
  end
end
