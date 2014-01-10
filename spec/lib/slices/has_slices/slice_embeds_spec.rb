require 'spec_helper'

describe Slices::HasSlices, ".slice_embeds" do

  it "has slice fields defined for Page" do
    Page.slice_embeds.should eq [:slices]
  end

  it "has slice fields defined for SetPage" do
    SetPage.slice_embeds.should eq [:slices, :set_slices]
  end
end

