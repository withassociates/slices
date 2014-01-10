require 'spec_helper'

describe Article, "#as_json" do

  let :article do
    home, parent = StandardTree.build_minimal_with_slices
    set_page, articles = StandardTree.add_article_set(home)
    articles.first
  end

  let :json_article do
    article.as_json
  end

  it "has page attributes" do
    json_article[:id].should eq article.id
    json_article[:name].should eq article.name
    json_article[:permalink].should eq article.permalink
  end

  it "has slice attributes" do
    slice = article.slices.first
    json_article[:slices][0][:title].should eq slice.title
  end

  it "has article attributes" do
    json_article[:published_at].should eq article.published_at
  end

end

