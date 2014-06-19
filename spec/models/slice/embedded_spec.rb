require 'spec_helper'

describe Slice, :type => :model do

  context "is embeded in a page" do
    let :page do
      Page.new(name: 'Page').tap do |page|
        page.slices << TestSlice.new
        page.save
      end
    end

    it "reference page" do
      slice = page.slices.first
      expect(slice.normal_page).to eq page
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
      expect(slice.normal_page).to eq page
      expect(slice.normal_or_set_page).to eq page
    end

    it "reference @page in set_slice" do
      slice = page.set_slices.first
      expect(slice.set_page).to eq page
      expect(slice.normal_or_set_page).to eq page
    end
  end

end

