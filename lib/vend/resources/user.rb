# frozen_string_literal: true

# Users

module Vend
  class User < Resource
    include Vend::ResourceActions.new uri: 'users'
  end
end
