# frozen_string_literal: true

# Outlets

module Vend
  class Outlet < Resource
    include Vend::ResourceActions.new uri: 'outlets'
  end
end
