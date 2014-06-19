require 'spec_helper'

describe Slice, type: :model do
  describe "with peers" do

    def add_slice(page, type, container, position)
      slice_class = Object.const_get("#{type}Slice".camelize)
      slice = slice_class.new(type => 'content', container: container, position: position)
      page.slices << slice
      page.save!
      slice
    end

    let :page do
      Page.make(name: 'Home')
    end

    let :slices do
      2.times do |i|
        position = (i + 1) % 2
        add_slice(page, :textile, 'container_one', position)
      end
      page.slices
    end

    let!(:first_by_position) { slices.second }
    let!(:second_by_position) { slices.first }

    it "know if it is the first in the container" do
      expect(first_by_position).to be_first_in_container
      expect(second_by_position).not_to be_first_in_container
    end

    it "know if it is the last in the container" do
      expect(second_by_position).to be_last_in_container
      expect(first_by_position).not_to be_last_in_container
    end

    context "in another container" do
      let(:alone_slice) { add_slice(page, :textile, 'container_two', 999) }

      it "not consider slices in another container as peers" do
        expect(second_by_position).to be_last_in_container
      end

      it "know that it is alone in the container" do
        expect(alone_slice).to be_alone_in_container
      end
    end

    it "know its position within the container" do
      expect(first_by_position.position_in_container).to eq 1
      expect(second_by_position.position_in_container).to eq 2
    end

    context "of different types" do
      let!(:third_by_position) { add_slice(page, :title, 'container_one', 3) }
      let!(:fourth_by_position) { add_slice(page, :textile, 'container_one', 4) }
      let!(:fifth_by_position) { add_slice(page, :textile, 'container_one', 5) }

      it "know if it is the first adjacent of type" do
        expect(first_by_position).to be_first_adjacent_of_type
        expect(third_by_position).to be_first_adjacent_of_type
        expect(fourth_by_position).to be_first_adjacent_of_type
        expect(second_by_position).not_to be_first_adjacent_of_type
        expect(fifth_by_position).not_to be_first_adjacent_of_type
      end

      it "know if it is the last adjacent of type" do
        expect(second_by_position).to be_last_adjacent_of_type
        expect(third_by_position).to be_last_adjacent_of_type
        expect(fifth_by_position).to be_last_adjacent_of_type
        expect(first_by_position).not_to be_last_adjacent_of_type
        expect(fourth_by_position).not_to be_last_adjacent_of_type
      end

      it "know that it is alone in adjacent of type" do
        expect(first_by_position).not_to be_alone_in_adjacent_of_type
        expect(second_by_position).not_to be_alone_in_adjacent_of_type
        expect(third_by_position).to be_alone_in_adjacent_of_type
        expect(fourth_by_position).not_to be_alone_in_adjacent_of_type
        expect(fifth_by_position).not_to be_alone_in_adjacent_of_type
      end

      it "know its position in adjacent of type" do
        1000.times { |i|
          expect(first_by_position.position_in_adjacent_of_type).to eq 1
          expect(second_by_position.position_in_adjacent_of_type).to eq 2
          expect(third_by_position.position_in_adjacent_of_type).to eq 1
          expect(fourth_by_position.position_in_adjacent_of_type).to eq 1
          expect(fifth_by_position.position_in_adjacent_of_type).to eq 2
        }
      end
    end
  end
end
