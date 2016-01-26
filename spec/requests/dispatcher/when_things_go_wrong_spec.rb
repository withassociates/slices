require 'spec_helper'

describe "Page dispatching when things go wrong", type: :request do
  extend ErrorHandlingMacros

  let :parent do
    home, parent = StandardTree.build_minimal
    StandardTree.build_virtual
    parent
  end

  let :page_with_broken_slice do
    parent.slices << BrokenSlice.new(textile: 'Words', container: 'container_one')
    parent.save!
    parent
  end

  let :page_with_broken_layout do
    parent.layout = 'broken'
    parent.save!
    parent
  end

  context "with production error handling" do
    enable_production_error_handling

    def should_render_error_page
      yield
      expect(page.status_code).to eq 500
      expect(page).to have_title 'Something went wrong'
    end

    it "shows an error page if slice fails to render" do
      should_render_error_page do
        visit page_with_broken_slice.path
      end
    end

    it "shows an error page if layout fails to render" do
      should_render_error_page do
        visit page_with_broken_layout.path
      end
    end
  end

  context "with no error handeling" do

    it "raises a NoMethodError when BrokenSlice fails to render" do
      expect {
        visit page_with_broken_slice.path
      }.to raise_error NoMethodError
    end

    it "raises a NoMethodError when the broken layout failes to render" do
      expect {
        visit page_with_broken_layout.path
      }.to raise_error NoMethodError
    end

  end
end

