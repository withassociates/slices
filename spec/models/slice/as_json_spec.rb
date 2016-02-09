require 'spec_helper'

describe Slice, type: :model do
  describe "#as_json" do

    let :slice do
      TextileSlice.new(container: 'container_one',
                       position: 0,
                       client_id: 'new1',
                       textile: 'Hello')
    end

    let :json_slice do
      slice.as_json
    end

    it "has slice attributes" do
      expect(json_slice['textile']).to eq 'Hello'
      expect(json_slice['container']).to eq 'container_one'
      expect(json_slice['position']).to eq 0
    end

    it "not have underscored attributes" do
      expect(json_slice).not_to include '_id'
      expect(json_slice).not_to include '_type'
    end

    it "uses client_id if the slice is new" do
      new_slice = Slice.new(client_id: 'new_123').as_json
      expect(new_slice['client_id']).to eq 'new_123'
    end

    it "returns the one field", i18n: true do
      expect(json_slice['textile']).to eq('Hello')
    end
  end
end
