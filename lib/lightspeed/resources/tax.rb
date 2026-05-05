# frozen_string_literal: true

# Taxes
# https://x-series-api.lightspeedhq.com/reference#taxes

module Lightspeed
  class Tax < Resource
    include Lightspeed::ResourceActions.new uri: 'taxes'

    read_scope  "taxes:read"
    write_scope "taxes:write"
  end
end
