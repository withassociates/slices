require 'spec_helper'

describe Layout do
  describe ".containers" do

    subject do
      Layout.new('default')
    end

    it 'finds all containers' do
      subject.containers.should == {
        'container_one' => { name: 'Container One', primary: true },
        'container_two' => { name: 'Container Two' },
      }
    end
  end
end
