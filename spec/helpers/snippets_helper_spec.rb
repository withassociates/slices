require 'spec_helper'

describe SnippetsHelper, type: :helper do

  def stub_snippet(key, result)
    expect(Snippet).to receive(:find_for_key).
      with(key).
      and_return(result)
  end

  context "#snippet" do
    it "is the snippet" do
      stub_snippet('address', '54B Downham Road')
      expect(snippet('address')).to eq '54B Downham Road'
    end

    it "allows HTML" do
      stub_snippet('address', 'With Associates<br />54B Downham Road')
      expect(snippet('address')).to eq 'With Associates<br />54B Downham Road'
    end

    it "handles missing keys" do
      expect(snippet('address')).to be_nil
    end
  end

  context "#localized_snippet" do
    before { @original_locale = I18n.locale }
    after { I18n.locale = @original_locale }

    it "is the localized snippet" do
      I18n.locale = :en
      stub_snippet('en.address', '54B Downham Road')

      expect(localized_snippet('address')).to eq '54B Downham Road'
    end

    it "is the localized snippet for a different locale" do
      I18n.locale = :de
      stub_snippet('de.address', '54B Untenschinken Strasse')

      expect(localized_snippet('address')).to eq '54B Untenschinken Strasse'
    end
  end
end
