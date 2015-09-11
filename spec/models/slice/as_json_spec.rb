require 'spec_helper'

describe Slice, type: :model do
  describe "#as_json" do

    let :slice do
      TitleSlice.new(title: 'Title',
                container: 'container_one',
                position: 0,
                client_id: 'new1')
    end

    let :json_slice do
      slice.as_json
    end

    it "has slice attributes" do
      expect(json_slice[:title]).to eq 'Title'
      expect(json_slice[:container]).to eq 'container_one'
      expect(json_slice[:position]).to eq 0
    end

    it "not have underscored attributes" do
      expect(json_slice).not_to include '_id'
      expect(json_slice).not_to include '_type'
    end

    it "uses client_id if the slice is new" do
      new_slice = Slice.new
      new_slice.client_id = 'new_123'
      expect(new_slice.as_json[:client_id]).to eq 'new_123'
    end

  end
end
