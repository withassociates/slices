# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'generators/slice/slice_generator'

describe SliceGenerator do
  destination Rails.root.join('tmp')

  before do
    prepare_destination
  end

  describe "rails g slice example" do
    before do
      run_generator %w(example)
    end

    it "creates example_slice.rb" do
      expect(file("app/slices/example/example_slice.rb")).to contain <<-CONTENT
        class ExampleSlice < Slice
          # For each field that you want to store on the slice, declare the
          # field as follow:
          # field :title
          # field :body
          #
          # You can also specify more complex fields like this:
          # field :potatoes, type: Array, default: []
          #
          # For date/time fields use the following convention:
          # field :published_on, type: Date
          # field :published_at, type: DateTime
          #
          # For more details of available fields, see the Mongoid
          # documentation: http://mongoid.org/docs/documents/fields.html
          #
          # You can also attach assets to a slice, like this:
          # has_attachments
          #
          # You can name your attachments like this:
          # has_attachments :images
          #
          # You can map your attachments to a custom class like this:
          # class Image < Attachment
          #   field :caption
          # end
          # has_attachments :images, class_name: "MySlice::Image"
        end
      CONTENT
    end

    it "creates templates/example.hbs" do
      expect(file("app/slices/example/templates/example.hbs")).to exist
    end

    it "creates views/show.html.erb" do
      expect(file("app/slices/example/views/show.html.erb")).to contain <<-CONTENT
        <div class="slice example">

          <!--
            Stick the HTML that should be rendered when your slice is displayed here.

            You can refer to data stored on your slice by calling slice.foo inside
            a normal ERB code block.
          -->

          <p>Change me by editing app/slices/example/views/show.html.erb</p>

        </div>
      CONTENT
    end
  end

  describe "rails g slice example title:string images:attachments featured_at:date_time confirmed:boolean description:text" do
    before do
      run_generator %w(example title:string images:attachments featured_at:date_time confirmed:boolean description:text)
    end

    it "creates example_slice.rb" do
      expect(file("app/slices/example/example_slice.rb")).to contain <<-CONTENT
        include Slices::HasAttachments
        field :title, type: String
        class Image < Attachment
          # Extend your attachments by adding fields here e.g.
          field :caption
        end
        has_attachments :images, class_name: 'ExampleSlice::Image'
        field :featured_at, type: DateTime
        field :confirmed,   type: Boolean
        field :description, type: String
      CONTENT
    end

    it "creates templates/example.hbs" do
      expect(file("app/slices/example/templates/example.hbs")).to contain <<-CONTENT
        <li>
          <label for="slices-{{id}}-title">Title</label>
          <input type="text" id="slices-{{id}}-title" placeholder="Title…" value="{{title}}">
        </li>
        <li>
          <label for="slices-{{id}}-images">Images</label>
          {{#attachmentComposer field="images"}}
            <textarea name="caption" placeholder="Caption…" class="full-height">{{caption}}</textarea>
          {{/attachmentComposer}}
        </li>
        <li>
          <label for="slices-{{id}}-featured_at">Featured at</label>
          {{dateField field="featured_at"}}
        </li>
        <li>
          <label>
            <input type="checkbox" id="slices-{{id}}-confirmed" data-value="{{confirmed}}">
            Confirmed
          </label>
        </li>
        <li>
          <label for="slices-{{id}}-description">Description</label>
          <textarea id="slices-{{id}}-description" placeholder="Description…" rows="24">{{description}}</textarea>
        </li>

        <!--
          To change the text that is displayed when this slice is minimised,
          use the `slicePreview` helper below. The method is scoped to this slice
          so you can easily access any contained elements.

          Examples:

            return this.find('textarea').val();
            return this.find('option:selected').text();

        -->
        {{#slicePreview}}
        {{/slicePreview}}

      CONTENT
    end

    it "creates views/show.html.erb" do
      expect(file("app/slices/example/views/show.html.erb")).to contain <<-CONTENT
        <div class="slice example">

          <!--
            Stick the HTML that should be rendered when your slice is displayed here.

            You can refer to data stored on your slice by calling slice.foo inside
            a normal ERB code block.
          -->

          <div class="title"><%= markdown slice.title %></div>

          <ul class="images">
            <%- slice.images.each do |image| -%>
              <li>
                <%= image_if_present image.asset, :original %>
                <div class="caption"><%= markdown image.caption %></div>
              </li>
            <%- end -%>
          </ul>

          <div class="featured_at"><%=l slice.featured_at %></div>

          <%- if slice.confirmed? -%>
            <div class="confirmed">Confirmed!</div>
          <%- end -%>

          <div class="description"><%= markdown slice.description %></div>

          <p>Change me by editing app/slices/example/views/show.html.erb</p>

        </div>
      CONTENT
    end
  end

  describe "rails g slice example example:text (a field whose name matches the slice name)" do
    before do
      run_generator %w(example example:text)
    end

    it "creates templates/examples.hbs without a label" do
      expect(file("app/slices/example/templates/example.hbs")).to contain <<-CONTENT
        <li>
          <textarea id="slices-{{id}}-example" placeholder="Example…" rows="24">{{example}}</textarea>
        </li>
      CONTENT
    end
  end

  describe "rails g slice example_form" do
    before do
      run_generator %w(example_form)
    end

    it "creates example_form_slice.rb with post handling options" do
      expect(file("app/slices/example_form/example_form_slice.rb")).to contain <<-CONTENT
        # The handle_post method will get passed the params from the POST
        # request, and should return true or false, depending on whether or
        # not processing was successful.
        #
        # def handle_post(params)
        # end
        #
        #
        # Form slices get a chance to set a flash message after they have
        # successfully handled a post. Set 'name' in the flash key to
        # something specific to this slice.
        #
        # def set_success_message(flash)
        #   flash['slices.name.notice'] = 'Nicely done'
        # end
        #
        #
        # After a successful POST request the CMS will redirect the user to a
        # URL (this prevents them from being able to re-submit the form by
        # reloading the page). This is the URL they end up at.
        #
        # def redirect_url
        #   '/path/to/a/page'
        # end
      CONTENT
    end

    it "creates show.html.erb with a form tag in place" do
      expect(file("app/slices/example_form/views/show.html.erb")).to contain <<-CONTENT
        <%= form_for slice, url: slice.page.path do |f| %>
          <!--
            Stick the HTML that should be rendered when your slice is displayed here.

            You can refer to data stored on your slice by calling slice.foo inside
            a normal ERB code block.

            For more information on available form helpers, see:
            http://guides.rubyonrails.org/form_helpers.html
          -->
          <p>Change me by editing app/slices/example_form/views/show.html.erb</p>
        <% end %>
      CONTENT
    end
  end

  describe "rails g slice example_set published_at:datetime --with-entry-templates --with-identical-entries" do
    before do
      run_generator %w(example_set published_at:datetime --with-entry-templates --with-identical-entries)
    end

    it "creates example.rb" do
      expect(file("app/slices/example_set/example.rb")).to contain <<-CONTENT
        class Example < Page
          field :published_at, type: DateTime

          def entry?
            true
          end

          def template
            "example_set/views/show"
          end

          # Uncomment the as_json method if the page defines fields that are
          # shown in the admin UI. Pass a hash to merge() that contains each
          # field.
          #
          # def as_json(options = {})
          #   super.merge(published: published.to_s)
          # end
        end
      CONTENT
    end

    it "creates example_presenter.rb" do
      expect(file("app/slices/example_set/example_presenter.rb")).to contain <<-CONTENT
        class ExamplePresenter < PagePresenter
          include EntryPresenter

          # We need to tell the admin UI which fields to show when presenting a
          # table of entries in the admin UI. Each key in the column hash should
          # be a symbol matching the name of one of the fields defined on the
          # page.
          #
          # The hash's values (e.g. 'Date Published') will be used for the
          # column headings in the admin UI.

          @columns = {
            name: 'Name',
            # published_at: 'Date Published'
          }
          class << self
            attr_reader :columns
          end

          def main_extra_templates
            super + ['example_set/example_main']
          end

          def meta_extra_templates
            super + ['example_set/example_meta']
          end

          # The CMS needs to know how to present the data stored on a page;
          # it's not always good enough just to convert it to a string and
          # render it into the page. You can access the page through the @source
          # variable.

          def name
            @source.name.blank? ? "(name isn't set)" : @source.name
          end
        end
      CONTENT
    end

    it "creates example_set_slice.rb" do
      expect(file("app/slices/example_set/example_set_slice.rb")).to contain <<-CONTENT
        class ExampleSetSlice < SetSlice
          restricted_slice

          def addable_entries?
            false
          end

          def editable_entries?
            false
          end
        end
      CONTENT
    end

    it "creates templates/example_main.hbs" do
      expect(file("app/slices/example_set/templates/example_main.hbs")).to contain <<-CONTENT
        <!--
          Any extra fields required for editing entries can be added here.

          For example:

          <li>
            <label for="meta-published_at">Published at</label>
            <input type="datetime" id="meta-published_at" value="{{published_at}}">
          </li>
        -->
      CONTENT
    end

    it "creates templates/example_meta.hbs" do
      expect(file("app/slices/example_set/templates/example_meta.hbs")).to contain <<-CONTENT
        <!--
          Any extra meta field required for editing entries can be added here.

          For example:

          <li>
            <label for="meta-published_at">Published at</label>
            <input type="datetime" id="meta-published_at" value="{{published_at}}">
          </li>
        -->
      CONTENT
    end

    it "creates templates/example_set.hbs" do
      expect(file("app/slices/example_set/templates/example_set.hbs")).to contain <<-CONTENT
        <li>
          <label for="slices-{{id}}-per_page">Per page</label>
          <input type="text" id="slices-{{id}}-per_page" value="{{per_page}}">
        </li>
      CONTENT
    end

    it "creates views/set.html.erb" do
      expect(file("app/slices/example_set/views/set.html.erb")).to contain <<-CONTENT
        <%= will_paginate slice.page_entries, renderer: SetLinkRenderer, class: 'pagination above' %>
        <ul class="entries">
          <% slice.page_entries.each do |entry| -%>
            <li><%= link_to entry.name, entry.path %></li>
          <% end -%>
        </ul>
        <%= will_paginate slice.page_entries, renderer: SetLinkRenderer, class: 'pagination below' %>
      CONTENT
    end
  end
end

