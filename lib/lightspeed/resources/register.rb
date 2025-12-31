# frozen_string_literal: true

# Registers
# https://x-series-api.lightspeedhq.com/reference#registers

module Lightspeed
  class Register < Resource
    include Lightspeed::ResourceActions.new uri: 'registers'
  end
end
