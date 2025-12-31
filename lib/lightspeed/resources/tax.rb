# frozen_string_literal: true

# Taxes
# https://x-series-api.lightspeedhq.com/reference#taxes

module Lightspeed
  class Tax < Resource
    include Lightspeed::ResourceActions.new uri: 'taxes'
  end
end
