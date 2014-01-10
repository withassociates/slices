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
    ArticlePresenter.headings.should eq ['Name', 'Content', 'Date Published']
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
      presenter.name.should eq 'Article 1'
      presenter.as_json['name'].should eq 'Article 1'
    end

    it "truncates the article's content" do
      slice = article.slices.detect do |slice|
        slice.kind_of?(TextileSlice)
      end
      slice.textile = '0123456789' * 10
      truncated = ('0123456789' * 6) + '...'

      presenter.content.should eq truncated
      presenter.as_json['content'].should eq truncated
    end

    it "knows the article's published_at date" do
      presenter.published_at.to_date.should eq published_at
      presenter.as_json['published_at'].to_date.should eq published_at
    end

    it "return the fields in the correct order" do
      values = [:name, :content, :published_at].map do |method|
        presenter.send(method)
      end

      presenter.fields.should eq values
    end

    it "know the article's _id" do
      presenter.as_json['_id'].should eq article.id
    end
  end

  context "when article is missing some data" do
    before do
      article.slices.each { |s| s.destroy }
      article.name = ''
      article.published_at = nil
    end

    it "say there is no name" do
      presenter.name.should eq '(no name)'
    end

    it "say there is no content" do
      presenter.content.should eq '(no content)'
    end

    it "say the article has no published_at date" do
      presenter.published_at.should eq '-'
    end
  end
end

