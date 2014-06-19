require 'spec_helper'

describe Page do
  describe "roles" do

    context "When creating virtual pages" do
      before do
        StandardTree.build_minimal
      end

      it "creates the not found page" do
        Page.make(role: 'not_found', name: 'Page not found')
        Page.find_virtual('not_found').name.should eq 'Page not found'
      end

      it "creates the error page" do
        Page.make(role: 'error', name: 'Whoops')
        Page.find_virtual('error').name.should eq 'Whoops'
      end
    end

    context "When finding virtual pages" do

      it "is able to return virtual page role for HTTP status code" do
        Page.role_for_status('500').should eq 'error'
        Page.role_for_status('404').should eq 'not_found'
        Page.role_for_status('123').should be_nil
      end

      it "returns all virtual pages for scope" do
        StandardTree.build_minimal
        not_found, error = StandardTree.build_virtual
        virtual_pages = Page.virtual

        virtual_pages.should include not_found
        virtual_pages.should include error
      end
    end

  end
end
