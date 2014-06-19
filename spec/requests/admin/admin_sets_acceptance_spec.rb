# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "The set entries view", type: :request, js: true do
  before do
    home, @page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    set_page, articles = StandardTree.add_article_set(@page)
    51.times { StandardTree.add_article(set_page) }
    # Define predictable order
    set_page.set_slice('Article').update_attributes(
      sort_field: 'name',
      sort_direction: 'asc'
    )
    visit admin_page_entries_path page_id: set_page.id
  end

  let :articles do
    Article.asc(:name)
  end

  it "displays the correct number on the first page" do
    expect(page).to have_css 'tbody tr', count: 50
  end

  it "displays the correct number on the second page" do
    jqtrigger '#pagination li:last-child a', :click
    expect(page).to have_css 'tbody tr', count: 3
  end

  it "links to the page editor", ci: false do
    article = articles.second
    click_on article.name

    expect(page).to have_css '#meta-name' # Stop next spec randomly failing
    expect(page).to have_field 'Page Name', with: article.name
  end
end

describe "Deleting an article from the entries view", type: :request, js: true do
  it "works as expected" do
    home, normal_page = StandardTree.build_minimal_with_slices
    sign_in_as_admin
    set_page, articles = StandardTree.add_article_set normal_page
    set_page.children.first.destroy

    visit admin_page_entries_path set_page
    expect(page).to have_css 'tbody tr', count: 1

    within('tbody tr:first-child') { click_on 'Delete' }

    expect(page).to have_no_css 'tbody tr'
    expect(page).to have_stopped_communicating
    expect(Article.count).to eq(0)
  end
end

describe "When sort_field is set to :position", type: :request, js: true do
  it "displays entries in order of position" do
    home, parent = StandardTree.build_minimal_with_slices
    set_page, articles = StandardTree.add_article_set parent
    Article.destroy_all

    set_slice = set_page.sets.first
    set_slice.sort_direction = 'asc'
    set_slice.sort_field = 'position'
    set_slice.save!

    first_entry = Article.make(
      parent: set_page,
      name: 'ZZZ',
      position: 0
    )
    second_entry = Article.make(
      parent: set_page,
      name: 'AAA',
      position: 1
    )
    thrid_entry = Article.make(
      parent: set_page,
      name: '111',
      position: 2
    )

    sign_in_as_admin
    visit admin_page_entries_path page_id: set_page.id

    expect(page.all('tbody .name a').map(&:text)).to eq(%w[ZZZ AAA 111])
  end
end
