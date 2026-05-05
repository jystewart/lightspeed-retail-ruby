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
      base.extend(Lightspeed::Scopes)
      base.extend(ClassMethods)
      options[:disable_methods] ||= []
      methods = ClassMethods.public_instance_methods & options[:disable_methods]
      methods.each { |name| base.send(:remove_method, name) }
    end

    module ClassMethods
      def all(params = {})
        check_scope!(:all)
        get path.build, params
      end

      def find(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        check_scope!(:find)
        get path.build(resource_id), params
      end

      def create(params = {})
        check_scope!(:create)
        post path.build, params
      end

      def update(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        check_scope!(:update)
        put path.build(resource_id), params
      end

      def destroy(resource_id, params = {})
        raise ArgumentError if resource_id.nil?
        check_scope!(:destroy)
        delete path.build(resource_id), params
      end

      def auto_paginate_v2(params = {})
        check_scope!(:auto_paginate_v2)
        results = []
        each_page_v2(params) { |page_data| results.concat(page_data) }
        results
      end

      def each_page_v2(params = {})
        check_scope!(:each_page_v2)
        loop do
          response = get(path.build, params)

          data = response[:data] || []
          yield data if data.any?

          break if data.empty?

          version_max = response.dig(:version, :max)
          break unless version_max

          params = params.merge(after: version_max)
        end
      end
    end
  end
end
