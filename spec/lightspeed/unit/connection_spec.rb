# frozen_string_literal: true

RSpec.describe Lightspeed::Connection do
  describe '.build' do
    let(:config) { Lightspeed::Config.new(domain_prefix: 'test', access_token: 'test_token') }

    it 'uses the Faraday default adapter when none is configured' do
      connection = described_class.build(config)
      expect(connection.builder.adapter).to eq(Faraday::Adapter.lookup_middleware(Faraday.default_adapter))
    end

    it 'uses the configured adapter' do
      config.adapter = :test
      connection = described_class.build(config)
      expect(connection.builder.adapter).to eq(Faraday::Adapter::Test)
    end

    it 'passes adapter options through when given as [name, options]' do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/2.0/test') { [200, {}, '{"data": []}'] }
      end
      config.adapter = [:test, stubs]
      connection = described_class.build(config)

      expect(connection.get('2.0/test').status).to eq(200)
    end
  end
end
