require 'spec_helper'

describe Page do

  let(:new_description) do
     'New description'
   end

   context "when changing description" do
    it "should update the meta_description" do
      page = Page.new
      page.description = new_description
      page.meta_description.should eq new_description
    end
  end

  context "when reading the description" do
    it "should get the meta_description" do
      page = Page.new(description: new_description)
      page.description.should eq page.meta_description
    end
  end
end
