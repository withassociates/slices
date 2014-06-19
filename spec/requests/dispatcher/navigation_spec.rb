
require 'spec_helper'

describe "Page dispatching with navigation", type: :request do

  def assert_primary_nav_link(text, href, html_class)
    expect(page).to have_css 'ul#primary_navigation' do
      assert_nav_link(text, href, html_class)
    end
  end

  def assert_secondary_nav_link(text, href, html_class)
    expect(page).to have_css 'ul#secondary_navigation' do
      assert_nav_link(text, href, html_class)
    end
  end

  before do
    @home, @parent = StandardTree.build_complex
    StandardTree.add_slices_beneath(@home)
  end

  context "on home page" do
    before do
      visit @home.path
    end

    it "mark home page as 'active'" do
      assert_primary_nav_link(@home.name, @home.path, 'active')
    end
  end

  context "on parent page" do
    before do
      visit @parent.path
    end

    it "mark parent as 'active'" do
      assert_primary_nav_link(@parent.name, @parent.path, 'active')
    end

    it "mark parent's first child as 'first'" do
      first = @parent.children.first
      assert_secondary_nav_link(first.name, first.path, 'first')
    end

    it "mark parent's last child as 'last'" do
      last = @parent.children.last
      assert_secondary_nav_link(last.name, last.path, 'last')
    end
  end
end
