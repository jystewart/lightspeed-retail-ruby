# frozen_string_literal: true

# Registers

module Vend
  class Register < Resource
    include Vend::ResourceActions.new uri: 'registers'
  end
end
