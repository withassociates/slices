require 'spec_helper'

describe Page, type: :model do
  let :new_description do
    'New description'
  end

  before do
    expect(ActiveSupport::Deprecation)
    .to receive(:warn)
    .with(Page::DESCRIPTION_DEPRECATION_WARNING)
    .at_least(:once)
  end

  context "when changing description" do
    it "should update the meta_description" do
      page = Page.new
      page.description = new_description
      expect(page.meta_description).to eq new_description
    end
  end

  context "when reading the description" do
    it "should get the meta_description" do
      page = Page.new(description: new_description)
      expect(page.description).to eq page.meta_description
    end
  end
end
