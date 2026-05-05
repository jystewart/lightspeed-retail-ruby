# frozen_string_literal: true

# Tags
# https://x-series-api.lightspeedhq.com/reference#tags

module Lightspeed
  class Tag < Resource
    include Lightspeed::ResourceActions.new uri: 'tags'

    read_scope  "products:read"
    write_scope "products:write"
  end
end
