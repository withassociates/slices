require 'spec_helper'

describe SnippetsHelper, type: :helper do

  def stub_snippet(result)
    expect(Snippet).to receive(:find_for_key).
      with('address').
      and_return(result)
  end

  context "#snippet" do
    before do
    end

    it "is the snippet" do
      stub_snippet('54B Downham Road')
      expect(snippet('address')).to eq '54B Downham Road'
    end

    it "allows HTML" do
      stub_snippet('With Associates<br />54B Downham Road')
      expect(snippet('address')).to eq 'With Associates<br />54B Downham Road'
    end

    it "handles missing keys" do
      stub_snippet(nil)
      expect(snippet('address')).to be_nil
    end
  end
end
