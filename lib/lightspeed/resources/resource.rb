# frozen_string_literal: true

require 'lightspeed/request'
require 'lightspeed/resource_actions'

module Lightspeed
  class Resource < Hashie::Trash
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::IgnoreUndeclared
  end
end
