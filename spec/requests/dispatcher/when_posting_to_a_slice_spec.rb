require 'spec_helper'

describe "When posting to a slice" do
  extend ErrorHandlingMacros
  enable_production_error_handling

  before do
    home, @parent = StandardTree.build_minimal
  end

  context "on a non-existent page" do
    before do
      StandardTree.build_virtual
      post '/no-such-page', hello: 'world'
    end

    it "returns a 404 status code" do
      assert_response :not_found
    end
  end

  context "on a page that doesn't have a slice to handle it" do
    before do
      StandardTree.build_virtual
      post @parent.path, hello: 'world'
    end

    it "return a 500 status code" do
      assert_response :error
    end
  end

  context "on page that has a slice that can handle it" do
    class DataHandlingSlice < Slice
      def handle_post(params)
        true
      end

      def set_success_message(flash)
      end

      def redirect_url
        '/new-url'
      end
    end

    before do
      @parent.slices << DataHandlingSlice.new(container: 'container_one')
      @parent.save!
      post @parent.path, hello: 'world'
    end

    it "process the POST data" do
      assert_response :redirect
      assert_redirected_to '/new-url'
    end
  end
end

