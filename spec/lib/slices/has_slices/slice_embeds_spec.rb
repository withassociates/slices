require 'spec_helper'

describe Slices::HasSlices do
  describe ".slice_embeds" do

    it "has slice fields defined for Page" do
      expect(Page.slice_embeds).to eq [:slices]
    end

    it "has slice fields defined for SetPage" do
      expect(SetPage.slice_embeds).to eq [:slices, :set_slices]
    end
  end
end
