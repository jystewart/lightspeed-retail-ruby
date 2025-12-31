# frozen_string_literal: true

module Lightspeed
  class ResourceActions < Module
    attr_reader :options

    def initialize(options = {})
      @options = options
      tap do |mod|
        mod.define_singleton_method :_options do
          mod.options
        end
      end
    end

    def included(base)
      base.send(:include, Request.new(options[:api_version], options[:uri]))
      base.extend(ClassMethods)
      options[:disable_methods] ||= []
      methods = ClassMethods.public_instance_methods & options[:disable_methods]
      methods.each { |name| base.send(:remove_method, name) }
    end

    module ClassMethods
      def all(params = {})
        get path.build, params
      end

      def find(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        get path.build(resource_id), params
      end

      def create(params = {})
        post path.build, params
      end

      def update(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        put path.build(resource_id), params
      end

      def destroy(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        delete path.build(resource_id), params
      end

      # Automatically paginate through all pages of results using v2.0 API cursor pagination.
      # Fetches all pages and returns a flat array of all data items.
      #
      # @param params [Hash] Query parameters to pass to the API
      # @return [Array] All items from all pages combined
      #
      # @example
      #   all_products = Lightspeed::Product.auto_paginate_v2
      #   deleted_products = Lightspeed::Product.auto_paginate_v2(deleted: true)
      def auto_paginate_v2(params = {})
        results = []
        each_page_v2(params) { |page_data| results.concat(page_data) }
        results
      end

      # Iterate through pages of results using v2.0 API cursor pagination.
      # Yields each page's data array to the block.
      #
      # @param params [Hash] Query parameters to pass to the API
      # @yield [Array] Each page's data array
      #
      # @example
      #   Lightspeed::Product.each_page_v2 do |products|
      #     products.each { |product| puts product[:name] }
      #   end
      def each_page_v2(params = {})
        loop do
          response = get(path.build, params)

          # Yield the data if there is any
          data = response[:data] || []
          yield data if data.any?

          # Check if there are more pages
          break if data.empty?

          # Get the cursor for the next page
          version_max = response.dig(:version, :max)
          break unless version_max

          # Set up params for next page
          params = params.merge(after: version_max)
        end
      end
    end
  end
end
