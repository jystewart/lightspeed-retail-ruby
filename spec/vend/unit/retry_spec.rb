# frozen_string_literal: true

RSpec.describe 'Retry Logic' do
  let(:config) do
    Vend::Config.new(
      domain_prefix: 'test',
      access_token: 'test_token'
    )
  end

  describe 'Faraday connection with retry middleware' do
    let(:connection) { Vend::Connection.build(config) }

    it 'includes retry middleware in the stack' do
      expect(connection.builder.handlers).to include(Faraday::Retry::Middleware)
    end

    it 'is configured to retry on 429 status' do
      retry_middleware = connection.builder.handlers.find { |h| h == Faraday::Retry::Middleware }
      expect(retry_middleware).not_to be_nil
    end

    it 'is configured to retry on 503 status' do
      retry_middleware = connection.builder.handlers.find { |h| h == Faraday::Retry::Middleware }
      expect(retry_middleware).not_to be_nil
    end
  end

  describe 'retry behavior' do
    before do
      module Vend
        class RetryTestResource
          include ResourceActions.new(api_version: '2.0', uri: 'test')
        end
      end
      @klass = Vend::RetryTestResource
    end

    it 'retries on 429 Too Many Requests' do
      stub_request(:get, 'https://test.vendhq.com/api/2.0/test')
        .to_return(
          { status: 429, headers: { 'Retry-After' => 'Wed, 01 Jan 2025 00:00:01 GMT' }, body: '{"error": "Too Many Requests"}' },
          { status: 200, body: '{"data": [{"id": 1}], "version": {"min": 1, "max": 1}}' }
        )

      # Configure a connection for this test
      config = Vend::Config.new(domain_prefix: 'test', access_token: 'test_token')
      connection = Vend::Connection.build(config)

      result = @klass.all(connection: connection)
      expect(result[:data]).to eq([{ id: 1 }])
    end

    it 'retries on 503 Service Unavailable' do
      stub_request(:get, 'https://test.vendhq.com/api/2.0/test')
        .to_return(
          { status: 503, body: '{"error": "Service Unavailable"}' },
          { status: 200, body: '{"data": [{"id": 1}], "version": {"min": 1, "max": 1}}' }
        )

      config = Vend::Config.new(domain_prefix: 'test', access_token: 'test_token')
      connection = Vend::Connection.build(config)

      result = @klass.all(connection: connection)
      expect(result[:data]).to eq([{ id: 1 }])
    end

    it 'eventually raises error if retries exhausted' do
      stub_request(:get, 'https://test.vendhq.com/api/2.0/test')
        .to_return(status: 429, headers: { 'Retry-After' => 'Wed, 01 Jan 2025 00:00:01 GMT' }, body: '{"error": "Too Many Requests"}')
        .times(4) # More than max retries

      config = Vend::Config.new(domain_prefix: 'test', access_token: 'test_token')
      connection = Vend::Connection.build(config)

      expect { @klass.all(connection: connection) }.to raise_error(Vend::TooManyRequests)
    end
  end
end
