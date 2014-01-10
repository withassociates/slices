class <%= class_name %>Slice < Slice
<%= field_definitions %>

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

<%- if form_slice? -%>
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
<%- end -%>
end

