require 'spec_helper'
require Rails.root.join 'spec/fixtures/slices/broken/broken_slice'

describe "Page dispatching when things go wrong" do
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
      page.status_code.should eq 500
      page.should have_css 'title', text: 'Something went wrong'
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
      lambda {
        visit page_with_broken_slice.path
      }.should raise_error NoMethodError
    end

    it "raises a NoMethodError when the broken layout failes to render" do
      lambda {
        visit page_with_broken_layout.path
      }.should raise_error NoMethodError
    end

  end
end

