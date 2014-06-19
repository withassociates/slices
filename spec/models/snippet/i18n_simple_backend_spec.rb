require 'spec_helper'

describe Snippet, type: :model do

  context "As a I18n simple backend" do

    it "translates keys" do
      Snippet.create(key: 'en.foo', value: 'bar')
      expect(I18n.translate('foo')).to eq 'bar'
    end

    it "does not translate missing keys" do
      expect(I18n.translate('foo')).to match /translation missing: en. ?foo/
    end

    it "translates with interpolations" do
      Snippet.create(key: 'en.foo', value: 'bar %{baz}')
      expect(I18n.translate('foo', baz: 'foo')).to eq 'bar foo'
    end

    it "translates with :" do
      Snippet.create(key: 'en.foo', value: 'bar:baz')
      expect(I18n.translate('foo')).to eq 'bar:baz'
    end
  end
end

