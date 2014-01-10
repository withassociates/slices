require 'spec_helper'

describe Layout, "#all" do

  subject { Layout.all }

  it 'finds layouts in app/view/layouts' do
    subject.should include(['Default', 'default'])
  end

  it 'finds layouts in test/fixtures/view/layouts' do
    subject.should include(['Layout One', 'layout_one'])
  end

  it 'ignores admin layout' do
    subject.should_not include(['Admin', 'admin'])
  end
end

