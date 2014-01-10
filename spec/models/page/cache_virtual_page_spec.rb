require 'spec_helper'

describe Page do

  context "#cache_virtual_page" do
    let :page do
      StandardTree.build_minimal.last
    end

    it "is called after save" do
      page.should_receive(:cache_virtual_page)
      page.save
    end
  end

end

