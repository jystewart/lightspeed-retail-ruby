# frozen_string_literal: true

# Taxes

module Vend
  class Tax < Resource
    include Vend::ResourceActions.new uri: 'taxes'
  end
end
