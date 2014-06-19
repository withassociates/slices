require 'spec_helper'

describe Layout, type: :model do
  describe ".containers" do

    subject do
      Layout.new('default')
    end

    it 'finds all containers' do
      expect(subject.containers).to eq({
        'container_one' => { name: 'Container One', primary: true },
        'container_two' => { name: 'Container Two' },
      })
    end
  end
end
