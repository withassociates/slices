require 'spec_helper'

describe ArticlePresenter do

  let :article do
    home, parent = StandardTree.build_minimal
    set_page, articles = StandardTree.add_article_set(home)
    article = articles.first
  end

  let :presenter do
    ArticlePresenter.new(article)
  end

  it "lists the columns to display" do
    expect(ArticlePresenter.headings).to eq ['Name', 'Content', 'Date Published']
  end

  context "when article has data" do
    let :published_at do
      DateTime.new(2011, 11, 5)
    end

    before do
      article.slices << TextileSlice.new(textile: 'Some content', container: 'container_one')
      article.published_at = published_at
    end

    it "knows the article's name" do
      expect(presenter.name).to eq 'Article 1'
      expect(presenter.as_json['name']).to eq 'Article 1'
    end

    it "truncates the article's content" do
      slice = article.slices.detect do |slice|
        slice.kind_of?(TextileSlice)
      end
      slice.textile = '0123456789' * 10
      truncated = ('0123456789' * 6) + '...'

      expect(presenter.content).to eq truncated
      expect(presenter.as_json['content']).to eq truncated
    end

    it "knows the article's published_at date" do
      expect(presenter.published_at.to_date).to eq published_at
      expect(presenter.as_json['published_at'].to_date).to eq published_at
    end

    it "return the fields in the correct order" do
      values = [:name, :content, :published_at].map do |method|
        presenter.send(method)
      end

      expect(presenter.fields).to eq values
    end

    it "know the article's _id" do
      expect(presenter.as_json['_id']).to eq article.id.to_s
    end
  end

  context "when article is missing some data" do
    before do
      article.slices.each { |s| s.destroy }
      article.name = ''
      article.published_at = nil
    end

    it "say there is no name" do
      expect(presenter.name).to eq '(no name)'
    end

    it "say there is no content" do
      expect(presenter.content).to eq '(no content)'
    end

    it "say the article has no published_at date" do
      expect(presenter.published_at).to eq '-'
    end
  end
end

