require 'spec_helper'

describe PagesController, type: :controller do
  describe "#render_page" do

    before do
      StandardTree.build_minimal
      PagesController.set_callback :render_page, :before, :my_callback
    end

    it "runs callbacks in render_page" do
      expect(controller).to receive(:my_callback).and_return(false)
      get :show
    end

    after do
      PagesController.reset_callbacks :render_page
    end
  end
end
