require 'spec_helper'

describe PagesHelper do

  describe "#if_t" do
    it "returns an empty string for blank Snippet" do
      Snippet.create(key: 'en.foo', value: '')
      if_t('foo').should eq ''
    end

    it "returns the translated string for Snippet" do
      Snippet.create(key: 'en.foo', value: 'bar')
      if_t('foo').should eq 'bar'
    end
  end

end

