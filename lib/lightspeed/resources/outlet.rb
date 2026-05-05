# frozen_string_literal: true

# Outlets
# https://x-series-api.lightspeedhq.com/reference#outlets

module Lightspeed
  class Outlet < Resource
    include Lightspeed::ResourceActions.new uri: 'outlets'

    read_scope "outlets:read"
  end
end
