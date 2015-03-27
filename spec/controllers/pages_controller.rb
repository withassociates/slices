require 'spec_helper'

describe PagesController, type: :controller do
  describe "#show" do
    let(:page) {
      Page.new(active: true)
    }

    before do
      allow(Page).to receive(:find_by_path).and_return(page)
    end

    it "generates an etag" do
      get :show
      expect(response.etag).to be_present
      expect(response.code).to eq '200'
    end

    context "with a an etag" do
      it "returns a 304" do
        etag = Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(page))
        request.env['HTTP_IF_NONE_MATCH'] = "\"#{etag}\""

        get :show
        expect(response.code).to eq '304'
      end
    end
  end
end
