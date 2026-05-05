RSpec.describe Lightspeed::ResourceActions do
  before do
    module Lightspeed
      class DummyClass
        include ResourceActions.new(api_version: '0.9', uri: 'http://foo.bar')
      end
    end
    @klass = Lightspeed::DummyClass
    Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token' }
  end

  after { Lightspeed.instance_variable_set(:@config, nil) }

  let(:params) do
    { page: 1 }
  end

  it 'should have options' do
    mod = Lightspeed::ResourceActions.new(
      uri: 'http://foo.bar',
      disable: [:find,:all]
    )
    options = {
      uri: 'http://foo.bar',
      disable: [:find,:all]
    }
    expect(mod._options).to eq options
  end

  it 'extends the class with Lightspeed::Scopes' do
    expect(@klass.singleton_class.ancestors).to include(Lightspeed::Scopes)
  end

  describe '.all' do
    it 'should make a get request to the correct route with query params' do
      expect(@klass).to receive(:get).with('http://foo.bar', {page: 1})
      @klass.all(params)
    end

    it 'should make a get request to the correct route' do
      expect(@klass).to receive(:get).with('http://foo.bar', {})
      params.delete(:params)
      @klass.all
    end

    context 'when scopes are configured and :all requires a scope' do
      before do
        Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token'; c.scopes = ["products:read"] }
        @klass.scope_required(:all, "sales:read")
      end

      it 'raises ScopeError when the required scope is missing' do
        expect { @klass.all }.to raise_error(Lightspeed::ScopeError, /sales:read/)
      end
    end

    context 'when scopes are configured and the required scope is present' do
      before do
        Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token'; c.scopes = ["sales:read"] }
        @klass.scope_required(:all, "sales:read")
      end

      it 'proceeds with the request' do
        expect(@klass).to receive(:get).with('http://foo.bar', {})
        @klass.all
      end
    end
  end

  describe '.find' do
    it 'should make a get request to the correct route' do
      expect(@klass).to receive(:get).with('http://foo.bar/1', {})
      @klass.find(1)
    end

    context 'when required scope is missing' do
      before do
        Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token'; c.scopes = ["products:read"] }
        @klass.scope_required(:find, "sales:read")
      end

      it 'raises ScopeError before making the HTTP request' do
        expect(@klass).not_to receive(:get)
        expect { @klass.find(1) }.to raise_error(Lightspeed::ScopeError)
      end
    end
  end

  describe '.create' do
    it 'should make a post request to the correct route with params' do
      expect(@klass).to receive(:post).with('http://foo.bar', {page: 1})
      @klass.create(params)
    end

    context 'when required scope is missing' do
      before do
        Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token'; c.scopes = ["products:read"] }
        @klass.scope_required(:create, "sales:write")
      end

      it 'raises ScopeError' do
        expect { @klass.create(params) }.to raise_error(Lightspeed::ScopeError)
      end
    end
  end

  describe '.update' do
    it 'should make a put request to the correct route with params' do
      expect(@klass).to receive(:put).with('http://foo.bar/1', {page: 1})
      @klass.update(1, params)
    end
  end

  describe '.destroy' do
    it 'should make a delete request to the correct route with params' do
      expect(@klass).to receive(:delete).with('http://foo.bar/1', {})
      @klass.destroy(1)
    end
  end

  describe 'scope checking is a no-op without configured scopes' do
    it 'does not raise when scopes are not configured, even with declared scope requirements' do
      @klass.scope_required(:all, "sales:read")
      expect(@klass).to receive(:get).with('http://foo.bar', {})
      @klass.all
    end
  end
end
