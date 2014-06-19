require 'spec_helper'

describe Snippet, type: :model do

  context "Snippet.find_value_by_key" do

    it "finds keys" do
      Snippet.create(key: 'en.foo', value: 'bar')
      expect(Snippet.find_value_by_key('en.foo')).to eq 'bar'
    end

    it "returns nil for missing keys" do
      expect(Snippet.find_value_by_key('foo')).to be_nil
    end

    it "translates with :" do
      Snippet.create(key: 'en.foo', value: 'bar:baz')
      expect(Snippet.find_value_by_key('en.foo')).to eq 'bar:baz'
    end

  end

end

