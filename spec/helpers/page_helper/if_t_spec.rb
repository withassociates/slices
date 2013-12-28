require 'spec_helper'

describe PagesHelper, type: :helper do

  describe "#if_t" do
    it "returns an empty string for blank Snippet" do
      Snippet.create(key: 'en.foo', value: '')
      expect(if_t('foo')).to eq ''
    end

    it "returns the translated string for Snippet" do
      Snippet.create(key: 'en.foo', value: 'bar')
      expect(if_t('foo')).to eq 'bar'
    end
  end
end

