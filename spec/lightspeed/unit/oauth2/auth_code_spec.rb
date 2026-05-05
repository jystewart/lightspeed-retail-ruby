RSpec.describe Lightspeed::Oauth2::AuthCode do
  subject { described_class.new('store', 'client_id', 'secret', 'redirect_uri') }

  describe '#initialize' do
    it 'sets up the attr_readers' do
      expect(subject.store).to        eq 'store'
      expect(subject.client_id).to    eq 'client_id'
      expect(subject.secret).to       eq 'secret'
      expect(subject.redirect_uri).to eq 'redirect_uri'
    end
  end

  it 'creates an instance of Client' do
    expect(subject).to be_a Lightspeed::Oauth2::AuthCode
  end

  describe '#authorize_url' do
    after { Lightspeed.instance_variable_set(:@config, nil) }

    it 'returns url without scope when no scopes are configured or passed' do
      expect(subject.authorize_url).to eq(
        'https://secure.retail.lightspeed.app/connect?client_id=client_id&redirect_uri=redirect_uri&response_type=code'
      )
    end

    it 'includes scope when passed as an array argument' do
      url = subject.authorize_url(scopes: ["sales:read", "products:read"])
      expect(url).to include('scope=sales%3Aread')
      expect(url).to include('products%3Aread')
    end

    it 'includes scope when passed as a space-delimited string argument' do
      url = subject.authorize_url(scopes: "sales:read products:read")
      expect(url).to include('scope=')
      expect(url).to include('sales')
      expect(url).to include('products')
    end

    it 'reads scopes from Lightspeed.config when not passed explicitly' do
      Lightspeed.configure do |c|
        c.domain_prefix = 'test'
        c.access_token  = 'token'
        c.scopes        = ["customers:read", "sales:read"]
      end
      url = subject.authorize_url
      expect(url).to include('scope=')
      expect(url).to include('customers')
      expect(url).to include('sales')
    end

    it 'explicit scopes take precedence over configured scopes' do
      Lightspeed.configure do |c|
        c.domain_prefix = 'test'
        c.access_token  = 'token'
        c.scopes        = ["customers:read"]
      end
      url = subject.authorize_url(scopes: ["sales:read"])
      expect(url).to include('sales')
      expect(url).not_to include('customers')
    end
  end

  describe '#token_from_code' do
    let(:store) { 'store' }
    let(:token_type) { 'Bearer' }
    let(:access_token) { 'Uy4eObSRn1RwzQbAitDMEkY6thdHsDJjwdGehpgr' }
    let(:refresh_token) { 'nbCoejmJp1XZgs7as6FeQQ5QZLlUfefzaBjrxvtV' }

    before do
      stub_request(:post, 'https://store.retail.lightspeed.app/api/1.0/token')
        .to_return(status: 200, body: { token_type: token_type,
                                        expires: 2_435_942_384,
                                        domain_prefix: store,
                                        access_token: access_token,
                                        refresh_token: refresh_token,
                                        expires_at: 2_435_942_383 }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'return access token' do
      token = subject.token_from_code('code')
      expect(token).to be_a OAuth2::AccessToken
      expect(token.token).to eq(access_token)
      expect(token.refresh_token).to eq(refresh_token)
    end
  end
end
