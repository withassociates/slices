require 'spec_helper'

describe Snippet, type: :model do

  context "Snippet.find_for_key" do

    it "finds keys" do
      Snippet.create(key: 'en.foo', value: 'bar')
      expect(Snippet.find_for_key('en.foo')).to eq 'bar'
    end

    it "returns nil for missing keys" do
      expect(Snippet.find_for_key('foo')).to be_nil
    end

    it "translates with :" do
      Snippet.create(key: 'en.foo', value: 'bar:baz')
      expect(Snippet.find_for_key('en.foo')).to eq 'bar:baz'
    end

    it "returns html_safe values" do
      Snippet.create(key: 'foo', value: 'bar')
      expect(Snippet.find_for_key('foo')).to be_html_safe
    end

  end

end

