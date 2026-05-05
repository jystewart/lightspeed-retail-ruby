# frozen_string_literal: true

# Sale
# https://x-series-api.lightspeedhq.com/reference#sales

module Lightspeed
  class Sale < Resource
    include Lightspeed::ResourceActions.new uri: 'sales'

    read_scope  "sales:read"
    write_scope "sales:write"
    scope_required :return,          "sales:write"
    scope_required :register_sale,   "sales:read"
    scope_required :finalize_return, "sales:write"

    def self.create(params = {})
      check_scope!(:create)
      post 'register_sales', params
    end

    def self.return(resource_id, params = {})
      check_scope!(:return)
      put "/api/2.0/sales/#{resource_id}/actions/return", params
    end

    def self.register_sale(resource_id, params = {})
      check_scope!(:register_sale)
      get "/api/register_sales/#{resource_id}", params
    end

    def self.finalize_return(params = {})
      check_scope!(:finalize_return)
      post '/api/register_sales', params
    end
  end
end
