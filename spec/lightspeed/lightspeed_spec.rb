RSpec.describe Lightspeed do
  let(:middleware) do
    api.instance_variable_get('@builder').instance_variable_get('@handlers')
  end

  it 'should return a faraday object when configured' do
    Lightspeed.configure do |config|
      config.api_key = '12345'
    end
    expect(Lightspeed.api).to be_a_kind_of(Faraday::Connection)
  end

  describe '.build_connection' do
    let(:api) do
      Lightspeed.configure do |config|
        config.api_key = '12345'
      end
    end

    it 'should have the correct auth middleware' do
      expect(middleware).to include(Lightspeed::Middleware::Auth)
    end
  end
end
