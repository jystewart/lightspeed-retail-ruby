# frozen_string_literal: true

# Customer Groups

module Vend
  class CustomerGroup < Resource
    include Vend::ResourceActions.new uri: 'customer_groups'
  end
end
