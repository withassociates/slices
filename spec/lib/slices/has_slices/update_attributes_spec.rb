require 'spec_helper'

describe Slices::HasSlices, "#update_attributes" do

  let :set_page do
    SetPage.create!(name: 'content')
  end

  let :json_slice do
    { "id" => slice_id.to_s, "type" => "title", "position" => 0,
      "title" => "Title", "container" => "container_one" }
  end

  let :slice_id do
    set_page.slices.first.id
  end

  before do
    set_page.slices.build({ title: "Title", container: "container_one" }, TitleSlice)
  end

  context "with an existing slice" do

    it "update the meta_description (on page)" do
      set_page.update_attributes({meta_description: 'Updated Description',
                                  slices: [json_slice]})
      set_page.reload

      set_page.meta_description.should eq "Updated Description"
    end

    it "update the title" do
      json_slice["title"] = "Updated Title"
      set_page.update_attributes({slices: [json_slice]})
      set_page.reload

      set_page.slices.first.title.should eq "Updated Title"
    end

    it "delete a slice" do
      json_slice[:_destroy] = true
      set_page.update_attributes({slices: [json_slice]})
      set_page.reload

      set_page.slices.length.should eq 0
    end

    it "create a slice" do
      new_slice = { "type" => "title", "position" => 1, "title" => "New Slice",
                    "container" => "container_one", "client_id" => "__new_1" }

      set_page.update_attributes({slices: [json_slice, new_slice]})
      new_slice = set_page.slices.last

      set_page.slices.length.should eq 2
      new_slice.class.should eq TitleSlice
      new_slice.title.should eq "New Slice"
    end

    it "create a slice with errors" do
      new_slice = { "type" => "title", "position" => 1, "title" => "",
                    "container" => "container_one", "client_id" => "__new_1" }

      json_slice['title'] = ''
      set_page.update_attributes({slices: [json_slice, new_slice] })
      new_slice = set_page.slices.last

      set_page.slices.length.should eq 2
      new_slice.class.should eq TitleSlice
      set_page.should_not be_valid
    end
  end

  context "with an existing slice and errors" do
    it "add errors to context via json" do
      json_slice["title"] = ""
      set_page.update_attributes({slices: [json_slice]})
      set_page.should_not be_valid
    end

    context "add errors 'normally'" do
      let :slice do
        set_page.slices.first
      end

      before do
        slice.title = ''
        slice.valid?
        set_page.valid?
      end

      it "not be valid?" do
        slice.should_not be_valid
        set_page.should_not be_valid
      end

      it "has errors on :slices" do
        set_page.errors.should include :slices
      end

      it "has error messages" do
        set_page.errors[:slices].first[slice.id][:title].first.should eq "can't be blank"
        set_page.slices.first.errors[:title].first.should eq "can't be blank"
      end

      it "converts the errors into JSON string" do
        error_json = { slices: [
          {slice.id => { title: ["can't be blank"]}}
        ] }.to_json

        #set_page.page_errors_with_slices_as_json.should eq error_json
        set_page.errors.to_json.should eq error_json
      end
    end
  end

  context "with slices on :slices & :set_slices" do
    let :set_slice_id do
      set_page.set_slices.first.id
    end

    let :json_set_slice do
      json_set_slice = { "id" => set_slice_id.to_s, "type" => "title",
                         "position" => 0, "title" => "Title",
                         "container" => "container_one" }
    end

    before do
      set_page.set_slices.build({ title: "Set Title",
                                  container: "container_one" }, TitleSlice)
    end

    it "has Title as title on set_slices" do
      set_page.save
      set_page.reload

      set_page.slices.length.should eq 1
      set_page.set_slices.length.should eq 1

      set_page.slices.first.title.should eq "Title"
      set_page.set_slices.first.title.should eq "Set Title"
    end

    it "update the title on both slice embeds" do
      json_slice["title"] = "Updated Title"
      json_set_slice["title"] = "Updated Set Title"
      set_page.update_attributes({slices: [json_slice],
                                  set_slices: [json_set_slice]})
      set_page.reload

      set_page.slices.first.title.should eq "Updated Title"
      set_page.set_slices.first.title.should eq "Updated Set Title"
    end
  end

end

