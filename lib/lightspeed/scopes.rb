# frozen_string_literal: true

module Lightspeed
  module Scopes
    READ_ACTIONS  = %i[all find auto_paginate_v2 each_page_v2].freeze
    WRITE_ACTIONS = %i[create update destroy].freeze

    # Declare or query the scope required for an action.
    #
    # With two arguments, registers the required scope(s) for the action:
    #   scope_required :all,    "sales:read"
    #   scope_required :create, %w[consignments:write:stock_order consignments:write:inventory_count]
    #
    # With one argument, returns the declared scope (or nil if none declared):
    #   Lightspeed::Sale.scope_required(:all)  #=> "sales:read"
    def scope_required(action, scope = nil)
      @scope_registry ||= {}
      if scope.nil?
        @scope_registry[action.to_sym]
      else
        @scope_registry[action.to_sym] = scope
      end
    end

    # Shorthand to declare the same read scope for all standard read actions
    # (all, find, auto_paginate_v2, each_page_v2).
    def read_scope(scope)
      READ_ACTIONS.each { |action| scope_required(action, scope) }
    end

    # Shorthand to declare the same write scope for all standard write actions
    # (create, update, destroy).
    def write_scope(scope)
      WRITE_ACTIONS.each { |action| scope_required(action, scope) }
    end

    # Raises ScopeError if the scope required for +action+ is not present in
    # the configured scopes. No-ops when:
    #   - Lightspeed.config has no scopes configured (backwards compatible)
    #   - The action has no declared scope requirement
    def check_scope!(action)
      configured = Array(Lightspeed.config&.scopes)
      return if configured.empty?

      required = scope_required(action.to_sym)
      return unless required

      required_array = Array(required)
      return if required_array.any? { |s| configured.include?(s) }

      raise Lightspeed::ScopeError.new(self, action, required)
    end
  end
end
