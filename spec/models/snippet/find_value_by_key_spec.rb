require 'spec_helper'

describe Snippet do

  context "Snippet.find_value_by_key" do

    it "finds keys" do
      Snippet.create(key: 'en.foo', value: 'bar')
      Snippet.find_value_by_key('en.foo').should eq 'bar'
    end

    it "returns nil for missing keys" do
      Snippet.find_value_by_key('foo').should be_nil
    end

    it "translates with :" do
      Snippet.create(key: 'en.foo', value: 'bar:baz')
      Snippet.find_value_by_key('en.foo').should eq 'bar:baz'
    end

  end

end

