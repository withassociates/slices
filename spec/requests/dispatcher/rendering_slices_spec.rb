require 'spec_helper'

describe "Rendering a page with slices" do
  before do
    home, parent = StandardTree.build_minimal_with_slices
    parent.slices.build({ textile: 'h3. Sub-sub heading', container: 'container_one', position: 2 }, TextileSlice)
    parent.slices.build({ textile: 'h2. Sub heading', container: 'container_one', position: 1 }, TextileSlice)
    parent.save!

    visit '/parent'
  end

  it "renders a title slice" do
    page.should have_css 'h1', text: 'Title'
  end

  it "renders a textile slice" do
    page.should have_css 'h2', text: 'Textile'
  end

  it "renders a slice in the correct container" do
    page.should have_css '.container_two h2', text: 'Textile'
  end

  it "renders titles in order" do
    page.should have_css '.container_one h1:nth-child(1)', text: 'Title'
    page.should have_css '.container_one h2:nth-child(2)', text: 'Sub heading'
    page.should have_css '.container_one h3:nth-child(3)', text: 'Sub-sub heading'
  end

end

