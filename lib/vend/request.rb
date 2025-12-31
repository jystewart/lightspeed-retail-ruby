# frozen_string_literal: true

require 'json'

module Vend
  class PathBuilder
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def build(key = nil)
      return uri unless key

      +"#{uri}/#{key}"
    end

    def to_s
      @uri
    end
  end

  class Request < Module
    def initialize(version, uri)
      @uri = case version
      in '0.9'
        uri
      in '1.0' | '2.0'
        "#{version}/#{uri}"
      else
        "2.0/#{uri}"
      end
    end

    def included(base)
      base.extend ClassMethods
      path_builder = PathBuilder.new @uri
      base.define_singleton_method :path do
        path_builder
      end
    end

    module ClassMethods
      def get(path, params = {})
        response = raw_request(:get, path, params)
        build_response_object response
      end

      def delete(path, params = {})
        response = raw_request(:delete, path, params)
        build_response_object(response)
      end

      def post(path, params = {})
        response = raw_request(:post, path, params)
        build_response_object response
      end

      def put(path, params = {})
        response = raw_request(:put, path, params)
        build_response_object response
      end

      def raw_request(method, path, params = {})
        client = params.delete(:connection) || Vend.api
        client.send(method, path.to_s, params)
      end

      private

      def build_response_object(response)
        parse response.body
      end

      def parse(json)
        return [] if json.empty?
        Oj.load(json, symbol_keys: true)
      end
    end
  end
end
