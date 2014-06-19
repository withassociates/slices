require 'spec_helper'

describe Page, type: :model do
  describe "roles" do

    context "When creating virtual pages" do
      before do
        StandardTree.build_minimal
      end

      it "creates the not found page" do
        Page.make(role: 'not_found', name: 'Page not found')
        expect(Page.find_virtual('not_found').name).to eq 'Page not found'
      end

      it "creates the error page" do
        Page.make(role: 'error', name: 'Whoops')
        expect(Page.find_virtual('error').name).to eq 'Whoops'
      end
    end

    context "When finding virtual pages" do

      it "is able to return virtual page role for HTTP status code" do
        expect(Page.role_for_status('500')).to eq 'error'
        expect(Page.role_for_status('404')).to eq 'not_found'
        expect(Page.role_for_status('123')).to be_nil
      end

      it "returns all virtual pages for scope" do
        StandardTree.build_minimal
        not_found, error = StandardTree.build_virtual
        virtual_pages = Page.virtual

        expect(virtual_pages).to include not_found
        expect(virtual_pages).to include error
      end
    end

  end
end
