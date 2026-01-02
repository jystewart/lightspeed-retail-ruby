# frozen_string_literal: true

# Tags

module Vend
  class Tag < Resource
    include Vend::ResourceActions.new uri: 'tags'
  end
end
