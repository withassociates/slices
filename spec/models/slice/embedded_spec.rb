require 'spec_helper'

describe Slice do

  context "is embeded in a page" do
    let :page do
      Page.new(name: 'Page').tap do |page|
        page.slices << TestSlice.new
        page.save
      end
    end

    it "reference page" do
      slice = page.slices.first
      slice.normal_page.should eq page
    end
  end

  context "is embeded in a set page" do
    let :page do
      SetPage.new(name: 'Set Page').tap do |page|
        page.slices << TestSlice.new
        page.set_slices << TestSlice.new
        page.save
      end
    end

    it "reference @page in slice" do
      slice = page.slices.first
      slice.normal_page.should eq page
      slice.normal_or_set_page.should eq page
    end

    it "reference @page in set_slice" do
      slice = page.set_slices.first
      slice.set_page.should eq page
      slice.normal_or_set_page.should eq page
    end
  end

end

