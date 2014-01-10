require 'spec_helper'

describe "A site with snippets" do

  before do
    home, page = StandardTree.build_minimal
    page.update_attributes(layout: 'layout_two')
  end

  it "renders snippets with plain text" do
    Snippet.create(key: 'en.address', value: '100 de Beauvoir Road')
    visit '/parent'

    page.should have_css 'footer p', '100 de Beauvoir Road'
  end

  it "renders snippets with html" do
    Snippet.create(key: 'en.address.html', value: '100 de Beauvoir Road<br />London')
    visit '/parent'

    page.should have_css 'footer p br'
  end

  it "renders snippets with symbols" do
    Snippet.create(key: 'en.address', value: 'nb:')
    visit '/parent'

    page.should have_css 'footer p', 'nb:'
  end

  it "renders nothing if the snippet has no value" do
    Snippet.create(key: 'en.address', value: '')
    visit '/parent'

    page.should have_css 'footer p', ''
  end

end
