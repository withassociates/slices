require 'spec_helper'

describe Snippet do

  context "As a I18n simple backend" do

    it "translates keys" do
      Snippet.create(key: 'en.foo', value: 'bar')
      I18n.translate('foo').should eq 'bar'
    end

    it "does not translate missing keys" do
      I18n.translate('foo').should match /translation missing: en. ?foo/
    end

    it "translates with interpolations" do
      Snippet.create(key: 'en.foo', value: 'bar %{baz}')
      I18n.translate('foo', baz: 'foo').should eq 'bar foo'
    end

    it "translates with :" do
      Snippet.create(key: 'en.foo', value: 'bar:baz')
      I18n.translate('foo').should eq 'bar:baz'
    end
  end
end

