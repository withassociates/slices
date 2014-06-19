require 'spec_helper'

describe Slices::HasSlices do
  describe "#update_attributes with multiple slices" do

    def add_slice(page, type, container, position)
      slice_class = Object.const_get("#{type}Slice".camelize)
      slice = slice_class.new(type => 'content', container: container,
                              position: position)
      page.slices << slice
      page.save!
      slice
    end

    def has_no_slice_with_textile(slices, text)
      slices.each do |slice|
        slice['textile'].should_not include text
      end
    end

    def has_slice_with_textile(slices, text)
      found = false
      slices.each do |slice|
        found = true if slice['textile'] == text
      end
      found.should be_true
      #assert_equal true, found, "Could not find a slice with '#{text}' in #{slices.inspect}"
    end

    def assert_all_slices_have_necessary_fields(slices)
      slices.each do |slice|
        slice.raw_attributes['position'].should_not be_nil
        slice.raw_attributes['_type'].should_not be_nil
        slice.raw_attributes['textile'].should_not be_nil
        slice.raw_attributes['container'].should_not be_nil
      end
    end

    def delete_slice(position)
      existing_slice position, _destroy: true
    end

    def new_slice(position)
      slice_attributes(position, {
        '_new' => '1',
        'client_id' => '__new__2',
      })
    end

    def existing_slice(position, options = {})
      slice_attributes(position, options.reverse_merge!({
        "id" => slices[position - 1].id.to_s,
      }))
    end

    def slice_attributes(position, options = {})
      options.reverse_merge!({
        "container" => "container_one",
        "position"  => position.to_s,
        "textile"   => position.to_s,
        "type"      => "textile"
      })
    end

    def page_attributes(slices)
      attributes = {
        'meta_description'  => "",
        'layout'            => "default",
        'permalink'         => "/",
        'position'          => "",
        'title'             => "",
        "slices"            => slices
      }
    end

    let :home do
      StandardTree.build_minimal.first
    end

    let! :slices do
      5.times do |i|
        position = (i + 1) % 2
        add_slice(home, :textile, 'container_one', position)
      end
      home.slices
    end

    it "has 5 slices, each with type & position" do
      slices.length.should eq 5
      slices.each do |slice|
        slice.raw_attributes['position'].should be
        slice.raw_attributes['_type'].should be
        slice.raw_attributes['textile'].should be
      end
    end

    context "and deleting one" do
      before do
        attributes = page_attributes([
          delete_slice(1),
          existing_slice(2),
          existing_slice(3),
          existing_slice(4),
          existing_slice(5),
        ])
        home.update_attributes(attributes)
      end

      it "has 4 slices, each with type, textile, position & container" do
        home.slices.length.should eq 4
        assert_all_slices_have_necessary_fields(home.slices)
      end

      it "has no slice with the textile '1'" do
        has_no_slice_with_textile(home.slices, '1')
      end

    end

    context "and deleting one and adding two" do
      before do
        attributes = page_attributes([
          delete_slice(1),
          existing_slice(2),
          existing_slice(3),
          existing_slice(4),
          existing_slice(5),
          new_slice(6),
          new_slice(7),
        ])
        home.update_attributes(attributes)
      end

      it "has 6 slices, each with type, textile, position & container" do
        home.slices.length.should eq 6
        assert_all_slices_have_necessary_fields(home.slices)
      end

      it "has no slice with the textile '1'" do
        has_no_slice_with_textile(home.slices, '1')
      end

      it "has slices with textile 6 & 7" do
        has_slice_with_textile(home.slices, '6')
        has_slice_with_textile(home.slices, '7')
      end

    end

    context "and deleting all existing and adding two" do
      before do
        attributes = page_attributes([
          delete_slice(1),
          delete_slice(2),
          delete_slice(3),
          delete_slice(4),
          delete_slice(5),
          new_slice(6),
          new_slice(7),
        ])
        home.update_attributes(attributes)
        @attr = attributes
      end

      it "has 2 slices, each with type, textile, position & container" do
        home.slices.length.should eq 2
        assert_all_slices_have_necessary_fields(home.slices)
      end

      it "has no slice with the textile 1 to 5" do
        (1..5).each do |num|
          has_no_slice_with_textile(home.slices, num.to_s)
        end
      end

      it "has slices with 6 and 7" do
        has_slice_with_textile(home.slices, '6')
        has_slice_with_textile(home.slices, '7')
      end

    end

    context "and deleting one and adding one at top" do
      before do
        attributes = page_attributes([
          new_slice(6),
          delete_slice(1),
          existing_slice(2),
          existing_slice(3),
          existing_slice(4),
          existing_slice(5),
        ])
        home.update_attributes(attributes)
      end

      it "has 5 slices, each with type, textile, position & container" do
        home.slices.length.should eq 5
        assert_all_slices_have_necessary_fields(home.slices)
      end

      it "has slices with 2 to 6" do
        (2..6).each do |num|
          has_slice_with_textile(home.slices, '6')
        end
      end

    end
  end
end
