# frozen_string_literal: true

RSpec.describe 'Pagination' do
  before do
    module Lightspeed
      class PaginatedResource
        include ResourceActions.new(api_version: '2.0', uri: 'products')
      end
    end
    @klass = Lightspeed::PaginatedResource
  end

  describe '.auto_paginate_v2' do
    context 'with multiple pages of results' do
      it 'fetches all pages automatically' do
        # First page
        expect(@klass).to receive(:get).with('2.0/products', {}).and_return(
          {
            data: [{ id: 1 }, { id: 2 }],
            version: { min: 100, max: 200 }
          }
        )

        # Second page
        expect(@klass).to receive(:get).with('2.0/products', { after: 200 }).and_return(
          {
            data: [{ id: 3 }, { id: 4 }],
            version: { min: 201, max: 300 }
          }
        )

        # Third page (empty, signals end)
        expect(@klass).to receive(:get).with('2.0/products', { after: 300 }).and_return(
          {
            data: [],
            version: { min: 0, max: 0 }
          }
        )

        results = @klass.auto_paginate_v2
        expect(results).to eq([{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }])
      end
    end

    context 'with a single page' do
      it 'returns all results from the single page' do
        expect(@klass).to receive(:get).with('2.0/products', {}).and_return(
          {
            data: [{ id: 1 }],
            version: { min: 100, max: 100 }
          }
        )

        expect(@klass).to receive(:get).with('2.0/products', { after: 100 }).and_return(
          {
            data: [],
            version: { min: 0, max: 0 }
          }
        )

        results = @klass.auto_paginate_v2
        expect(results).to eq([{ id: 1 }])
      end
    end

    context 'with custom parameters' do
      it 'preserves custom parameters across pages' do
        expect(@klass).to receive(:get).with('2.0/products', { deleted: true }).and_return(
          {
            data: [{ id: 1 }],
            version: { min: 100, max: 200 }
          }
        )

        expect(@klass).to receive(:get).with('2.0/products', { deleted: true, after: 200 }).and_return(
          {
            data: [],
            version: { min: 0, max: 0 }
          }
        )

        results = @klass.auto_paginate_v2(deleted: true)
        expect(results).to eq([{ id: 1 }])
      end
    end

    context 'with empty initial response' do
      it 'returns an empty array' do
        expect(@klass).to receive(:get).with('2.0/products', {}).and_return(
          {
            data: [],
            version: { min: 0, max: 0 }
          }
        )

        results = @klass.auto_paginate_v2
        expect(results).to eq([])
      end
    end
  end

  describe '.each_page_v2' do
    it 'yields each page of results' do
      expect(@klass).to receive(:get).with('2.0/products', {}).and_return(
        {
          data: [{ id: 1 }, { id: 2 }],
          version: { min: 100, max: 200 }
        }
      )

      expect(@klass).to receive(:get).with('2.0/products', { after: 200 }).and_return(
        {
          data: [{ id: 3 }],
          version: { min: 201, max: 300 }
        }
      )

      expect(@klass).to receive(:get).with('2.0/products', { after: 300 }).and_return(
        {
          data: [],
          version: { min: 0, max: 0 }
        }
      )

      pages = []
      @klass.each_page_v2 { |page| pages << page }

      expect(pages.length).to eq(2)
      expect(pages[0]).to eq([{ id: 1 }, { id: 2 }])
      expect(pages[1]).to eq([{ id: 3 }])
    end
  end
end
