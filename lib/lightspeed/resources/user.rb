# frozen_string_literal: true

# Users
# https://x-series-api.lightspeedhq.com/reference#users-2

module Lightspeed
  class User < Resource
    include Lightspeed::ResourceActions.new uri: 'users'

    read_scope  "users:read"
    write_scope "users:write"
  end
end
