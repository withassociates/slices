require 'spec_helper'

describe Slice, "#as_json" do

  let :slice do
    Slice.new(title: 'Title',
              container: 'container_one',
              position: 0,
              client_id: 'new1')
  end

  let :json_slice do
    slice.as_json
  end

  it "has slice attributes" do
    json_slice[:title].should eq 'Title'
    json_slice[:container].should eq 'container_one'
    json_slice[:position].should eq 0
  end

  it "not have underscored attributes" do
    json_slice.should_not include '_id'
    json_slice.should_not include '_type'
  end

  it "uses client_id if the slice is new" do
    new_slice = Slice.new(client_id: 'new_123').as_json
    new_slice[:client_id].should eq 'new_123'
  end

end

