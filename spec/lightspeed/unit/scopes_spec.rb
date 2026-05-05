RSpec.describe Lightspeed::Scopes do
  let(:resource_class) do
    Class.new do
      extend Lightspeed::Scopes
      def self.name; "Lightspeed::FakeResource"; end
    end
  end

  after { Lightspeed.instance_variable_set(:@config, nil) }

  describe '.scope_required' do
    it 'returns nil for undeclared actions' do
      expect(resource_class.scope_required(:all)).to be_nil
    end

    it 'registers and returns a single scope string' do
      resource_class.scope_required(:all, "sales:read")
      expect(resource_class.scope_required(:all)).to eq("sales:read")
    end

    it 'registers and returns an array of scopes' do
      resource_class.scope_required(:create, %w[consignments:write:stock_order consignments:write:inventory_count])
      expect(resource_class.scope_required(:create)).to eq(%w[consignments:write:stock_order consignments:write:inventory_count])
    end

    it 'accepts symbol or string for action lookup' do
      resource_class.scope_required(:find, "products:read")
      expect(resource_class.scope_required("find")).to eq("products:read")
    end

    it 'is isolated per class' do
      other_class = Class.new { extend Lightspeed::Scopes }
      resource_class.scope_required(:all, "sales:read")
      expect(other_class.scope_required(:all)).to be_nil
    end
  end

  describe '.read_scope' do
    before { resource_class.read_scope("products:read") }

    it 'sets scope for :all' do
      expect(resource_class.scope_required(:all)).to eq("products:read")
    end

    it 'sets scope for :find' do
      expect(resource_class.scope_required(:find)).to eq("products:read")
    end

    it 'sets scope for :auto_paginate_v2' do
      expect(resource_class.scope_required(:auto_paginate_v2)).to eq("products:read")
    end

    it 'sets scope for :each_page_v2' do
      expect(resource_class.scope_required(:each_page_v2)).to eq("products:read")
    end

    it 'does not set scope for write actions' do
      expect(resource_class.scope_required(:create)).to be_nil
      expect(resource_class.scope_required(:update)).to be_nil
      expect(resource_class.scope_required(:destroy)).to be_nil
    end
  end

  describe '.write_scope' do
    before { resource_class.write_scope("products:write") }

    it 'sets scope for :create' do
      expect(resource_class.scope_required(:create)).to eq("products:write")
    end

    it 'sets scope for :update' do
      expect(resource_class.scope_required(:update)).to eq("products:write")
    end

    it 'sets scope for :destroy' do
      expect(resource_class.scope_required(:destroy)).to eq("products:write")
    end

    it 'does not set scope for read actions' do
      expect(resource_class.scope_required(:all)).to be_nil
      expect(resource_class.scope_required(:find)).to be_nil
    end
  end

  describe '.check_scope!' do
    context 'when no scopes are configured' do
      before do
        Lightspeed.configure { |c| c.domain_prefix = 'test'; c.access_token = 'token' }
      end

      it 'does not raise even if a scope is declared' do
        resource_class.scope_required(:all, "sales:read")
        expect { resource_class.check_scope!(:all) }.not_to raise_error
      end

      it 'does not raise for actions with no declared scope' do
        expect { resource_class.check_scope!(:all) }.not_to raise_error
      end
    end

    context 'when scopes are configured' do
      before do
        Lightspeed.configure do |c|
          c.domain_prefix = 'test'
          c.access_token  = 'token'
          c.scopes        = ["sales:read", "products:read"]
        end
      end

      it 'does not raise when the required scope is configured' do
        resource_class.scope_required(:all, "sales:read")
        expect { resource_class.check_scope!(:all) }.not_to raise_error
      end

      it 'does not raise when the action has no declared scope requirement' do
        expect { resource_class.check_scope!(:all) }.not_to raise_error
      end

      it 'raises ScopeError when the required scope is missing' do
        resource_class.scope_required(:all, "customers:read")
        expect { resource_class.check_scope!(:all) }.to raise_error(Lightspeed::ScopeError)
      end

      it 'includes the resource, action and required scope in the error message' do
        resource_class.scope_required(:create, "sales:write")
        error = capture_error { resource_class.check_scope!(:create) }
        expect(error.message).to include("FakeResource")
        expect(error.message).to include("create")
        expect(error.message).to include("sales:write")
      end

      context 'with an array of required scopes (any-of semantics)' do
        let(:consignment_write_scopes) do
          %w[consignments:write:inventory_count consignments:write:stock_order consignments:write:stock_transfer]
        end

        before { resource_class.scope_required(:create, consignment_write_scopes) }

        it 'does not raise when any of the required scopes is configured' do
          Lightspeed.configure do |c|
            c.domain_prefix = 'test'
            c.access_token  = 'token'
            c.scopes        = ["consignments:write:stock_order"]
          end
          expect { resource_class.check_scope!(:create) }.not_to raise_error
        end

        it 'raises ScopeError when none of the required scopes are configured' do
          Lightspeed.configure do |c|
            c.domain_prefix = 'test'
            c.access_token  = 'token'
            c.scopes        = ["sales:read"]
          end
          expect { resource_class.check_scope!(:create) }.to raise_error(Lightspeed::ScopeError)
        end

        it 'lists all options in the error message' do
          Lightspeed.configure do |c|
            c.domain_prefix = 'test'
            c.access_token  = 'token'
            c.scopes        = ["sales:read"]
          end
          error = capture_error { resource_class.check_scope!(:create) }
          expect(error.message).to include("consignments:write:stock_order")
          expect(error.message).to include("consignments:write:inventory_count")
        end
      end
    end

    context 'when Lightspeed.config is nil' do
      before { Lightspeed.instance_variable_set(:@config, nil) }

      it 'does not raise' do
        resource_class.scope_required(:all, "sales:read")
        expect { resource_class.check_scope!(:all) }.not_to raise_error
      end
    end
  end

  describe 'Lightspeed::ScopeError' do
    it 'formats the message for a single required scope' do
      error = Lightspeed::ScopeError.new("Lightspeed::Sale", :all, "sales:read")
      expect(error.message).to eq(
        "Lightspeed::Sale.all requires OAuth scope 'sales:read'. " \
        "Add it to your Lightspeed.configure block: config.scopes = [\"sales:read\"]"
      )
    end

    it 'formats the message for multiple required scopes' do
      scopes = %w[consignments:write:inventory_count consignments:write:stock_order]
      error = Lightspeed::ScopeError.new("Lightspeed::Consignment", :create, scopes)
      expect(error.message).to include("one of")
      expect(error.message).to include("consignments:write:inventory_count")
      expect(error.message).to include("consignments:write:stock_order")
    end
  end

  describe 'scope declarations on built-in resources' do
    it 'Sale declares sales:read for read actions' do
      expect(Lightspeed::Sale.scope_required(:all)).to    eq("sales:read")
      expect(Lightspeed::Sale.scope_required(:find)).to   eq("sales:read")
    end

    it 'Sale declares sales:write for write actions' do
      expect(Lightspeed::Sale.scope_required(:create)).to  eq("sales:write")
      expect(Lightspeed::Sale.scope_required(:update)).to  eq("sales:write")
      expect(Lightspeed::Sale.scope_required(:destroy)).to eq("sales:write")
    end

    it 'Sale declares sales:write for custom write actions' do
      expect(Lightspeed::Sale.scope_required(:return)).to          eq("sales:write")
      expect(Lightspeed::Sale.scope_required(:finalize_return)).to eq("sales:write")
    end

    it 'Sale declares sales:read for register_sale' do
      expect(Lightspeed::Sale.scope_required(:register_sale)).to eq("sales:read")
    end

    it 'Product declares products:read for read actions' do
      expect(Lightspeed::Product.scope_required(:all)).to  eq("products:read")
      expect(Lightspeed::Product.scope_required(:find)).to eq("products:read")
    end

    it 'Product declares inventory:read for the inventory action' do
      expect(Lightspeed::Product.scope_required(:inventory)).to eq("inventory:read")
    end

    it 'Customer declares customers:read/write' do
      expect(Lightspeed::Customer.scope_required(:all)).to    eq("customers:read")
      expect(Lightspeed::Customer.scope_required(:create)).to eq("customers:write")
    end

    it 'Consignment declares consignments:read for reads' do
      expect(Lightspeed::Consignment.scope_required(:all)).to eq("consignments:read")
    end

    it 'Consignment declares an array of write scopes' do
      write_scopes = Lightspeed::Consignment.scope_required(:create)
      expect(write_scopes).to be_an(Array)
      expect(write_scopes).to include("consignments:write:stock_order")
      expect(write_scopes).to include("consignments:write:inventory_count")
      expect(write_scopes).to include("consignments:write:stock_transfer")
    end

    it 'Webhook declares webhooks scope for all actions' do
      expect(Lightspeed::Webhook.scope_required(:all)).to    eq("webhooks")
      expect(Lightspeed::Webhook.scope_required(:create)).to eq("webhooks")
      expect(Lightspeed::Webhook.scope_required(:destroy)).to eq("webhooks")
    end

    it 'PriceBook declares price book scopes' do
      expect(Lightspeed::PriceBook.scope_required(:all)).to    eq("products:read:price_books")
      expect(Lightspeed::PriceBook.scope_required(:create)).to eq("products:write:price_books")
    end

    it 'Inventory declares inventory:read' do
      expect(Lightspeed::Inventory.scope_required(:all)).to eq("inventory:read")
    end

    it 'Outlet declares outlets:read' do
      expect(Lightspeed::Outlet.scope_required(:all)).to eq("outlets:read")
    end
  end

  private

  def capture_error(&block)
    block.call
    nil
  rescue => e
    e
  end
end
