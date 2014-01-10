class SliceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  argument :attributes,
           type: :array,
           default: [],
           banner: "field:type field:type"

  class_option :with_entry_templates, type: :boolean, default: false,
               desc: "Add templates for editing entry content."

  class_option :with_identical_entries, type: :boolean, default: false,
               desc: "For sets whose entry pages are all alike."

  FIELD_NORMALIZATIONS = {
    text: :string,
    datetime: :date_time
  }

  def create_slices
    if set_slice?
      template "set_slice.rb", "#{slice_path}/#{file_name}_slice.rb"
    else
      template "slice.rb", "#{slice_path}/#{file_name}_slice.rb"
    end
  end

  def create_views
    if set_slice?
      template "set.html.erb", "#{slice_path}/views/set.html.erb"
    else
      template "show.html.erb", "#{slice_path}/views/show.html.erb"
    end
  end

  def create_templates
    if set_slice?
      template "set_slice_fields.hbs", "#{slice_path}/templates/#{file_name}.hbs"
    else
      template "slice_fields.hbs", "#{slice_path}/templates/#{file_name}.hbs"
    end

    base = set_slice? ? page_name : file_name

    if options.with_entry_templates?
      template "main_fields.hbs", "#{slice_path}/templates/#{base}_main.hbs"
      template "meta_fields.hbs", "#{slice_path}/templates/#{base}_meta.hbs"
    end
  end

  def create_set_files
    if set_slice?
      template "page.rb", "#{slice_path}/#{page_name}.rb"
      template "presenter.rb", "#{slice_path}/#{page_name}_presenter.rb"
    end
  end


  private

  def slice_path
    "app/slices/#{file_name}"
  end

  def page_name
    file_name.sub /_set$/, ''
  end

  def set_slice?
    file_name.ends_with? '_set'
  end

  def form_slice?
    file_name.ends_with? '_form'
  end

  def field_definitions
    out = []

    if attributes.any? { |attribute| attribute.type == :attachments }
      out << "  include Slices::HasAttachments\n"
    end

    attributes.each do |attribute|
      case attribute.type
      when :attachments
        attachment_klass = attribute.name.classify
        out << [
          "",
          "  class #{attachment_klass} < Attachment",
          "    # Extend your attachments by adding fields here e.g.",
          "    field :caption",
          "  end",
          "  has_attachments :#{attribute.name}, class_name: '#{class_name}Slice::#{attachment_klass}'",
          ""
        ].join("\n")
      else
        out << "  field :#{attribute.name}, type: #{class_for_field attribute.type}"
      end
    end

    out.join "\n"
  end

  def slice_input_id name
    "slices-{{id}}-#{name}"
  end

  def needs_label? attribute
    attribute.name.underscore == class_name.underscore
  end

  def label_if_needed_for attribute
    unless attribute.name == file_name
      %{<label for="slices-{{id}}-#{attribute.name}">#{attribute.name.humanize}</label>}
    end
  end

  def class_for_field type
    FIELD_NORMALIZATIONS.fetch(type, type).to_s.classify
  end

end
