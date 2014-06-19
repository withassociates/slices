require 'spec_helper'

describe Layout do
  describe "#files" do

    subject { Layout.files.map { |p| p.split('/').last } }

    it 'finds layouts in app/view/layouts' do
      subject.should include('default.html.erb')
    end

    it 'finds layouts in test/fixtures/view/layouts' do
      subject.should include('layout_one.html.erb')
    end

    it 'ignores admin layout' do
      subject.should_not include('admin.html.erb')
    end
  end
end
