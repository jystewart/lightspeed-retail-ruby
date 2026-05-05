# frozen_string_literal: true

# Products
# https://x-series-api.lightspeedhq.com/reference#products-2

module Lightspeed
  class Product < Resource
    include Lightspeed::ResourceActions.new uri: 'products'

    read_scope  "products:read"
    write_scope "products:write"
    scope_required :find_v0_9,       "products:read"
    scope_required :inventory,       "inventory:read"
    scope_required :update_inventory, "products:write"
    scope_required :image_upload,    "products:write"

    def self.find_v0_9(resource_id, params = {})
      check_scope!(:find_v0_9)
      get "products/#{resource_id}", params
    end

    def self.update(params = {})
      check_scope!(:update)
      post 'products', params
    end

    def self.inventory(resource_id, params = {})
      check_scope!(:inventory)
      get "2.0/products/#{resource_id}/inventory", params
    end

    def self.update_inventory(params = {})
      check_scope!(:update_inventory)
      post 'products', params
    end

    def self.image_upload(resource_id, params)
      check_scope!(:image_upload)
      connection = params[:connection] || Vend.api
      response = connection.post do |req|
        req.url "2.0/products/#{resource_id}/actions/image_upload"
        req.body = { image: params[:image] }
      end
      Oj.load(response.body, symbol_keys: true)
    end
  end
end
