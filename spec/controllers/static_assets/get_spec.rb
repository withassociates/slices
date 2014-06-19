require 'spec_helper'

describe StaticAssetsController, type: :controller do

  context "GET :templates" do
    it "serve shared templates" do
      get :templates, name: 'page_meta', format: 'hbs'

      expect(response).to be_success
    end

    it "serve slice templates" do
      get :templates, slice: 'article_set', name: 'article_meta', format: 'hbs'

      expect(response).to be_success
    end
  end

end
