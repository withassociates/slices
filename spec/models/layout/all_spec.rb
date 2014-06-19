require 'spec_helper'

describe Layout, type: :model do
  describe "#all" do

    subject { Layout.all }

    it 'finds layouts in app/view/layouts' do
      expect(subject).to include(['Default', 'default'])
    end

    it 'finds layouts in test/fixtures/view/layouts' do
      expect(subject).to include(['Layout One', 'layout_one'])
    end

    it 'ignores admin layout' do
      expect(subject).not_to include(['Admin', 'admin'])
    end

  end
end
