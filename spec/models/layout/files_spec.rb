require 'spec_helper'

describe Layout, type: :model do
  describe "#files" do

    subject { Layout.files.map { |p| p.split('/').last } }

    it 'finds layouts in app/view/layouts' do
      expect(subject).to include('default.html.erb')
    end

    it 'finds layouts in test/fixtures/view/layouts' do
      expect(subject).to include('layout_one.html.erb')
    end

    it 'ignores admin layout' do
      expect(subject).not_to include('admin.html.erb')
    end
  end
end
