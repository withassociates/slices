module Slices
  class CmsFormBuilder < ActionView::Helpers::FormBuilder

    FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
      html_tag
    end

    %w{email_field password_field select text_area text_field}.each do |selector|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def cms_#{selector}(attribute, options = {})       # def cms_text_field(attribute, options = {})
          wrap_field(:#{selector}, attribute, options)     #   wrap_field(:text_field, attribute, options)
        end                                                # end
      RUBY_EVAL
    end

    private

    def wrap_field(selector, attribute, options)
      with_custom_field_error_proc do
        content = send(selector, attribute, options)
        options = {}
        errors = @object.errors[attribute]

        if errors.any?
          options[:class] = 'error'
          content << @template.send(:content_tag, :p, errors.join(' and '))
        end

        @template.content_tag(:li, label(attribute) + content, options)
      end
    end

    def with_custom_field_error_proc(&block)
      default_field_error_proc = ::ActionView::Base.field_error_proc
      ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
      yield
    ensure
      ::ActionView::Base.field_error_proc = default_field_error_proc
    end
  end

end
