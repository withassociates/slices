require 'spec_helper'

describe Page, type: :model do
  before do
    expect(Layout).to receive(:all).and_return([["Default", "default"]])
  end

  describe ".available_layouts" do
    subject do
      Page.available_layouts
    end

    it "returns an array of layouts as { :human_name => '', :machine_name => ''}" do
      is_expected.to eq([ { human_name: "Default", machine_name: "default" } ])
    end
  end

  describe "#available_layouts" do
    subject do
      Page.new(layout: "default").available_layouts
    end

    it "returns an array of layouts, with one marked as selected" do
      is_expected.to eq([ { human_name: "Default", machine_name: "default" } ])
    end
  end

end
