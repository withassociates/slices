require 'spec_helper'

describe Article, type: :model do
  describe "#as_json" do

    let :article do
      home, parent = StandardTree.build_minimal_with_slices
      set_page, articles = StandardTree.add_article_set(home)
      articles.first
    end

    let :json_article do
      article.as_json
    end

    it "has page attributes" do
      expect(json_article[:id]).to eq article.id.to_s
      expect(json_article[:name]).to eq article.name
      expect(json_article[:permalink]).to eq article.permalink
    end

    it "has slice attributes" do
      slice = article.slices.first
      expect(json_article[:slices][0][:title]).to eq slice.title
    end

    it "has article attributes" do
      expect(json_article[:published_at]).to eq article.published_at
    end

  end
end
