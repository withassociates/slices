module RSpec::Rails
  module ApiExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Integration::Runner
    include ActionDispatch::Assertions
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    def app
      ::Rails.application
    end

    def json_response
      JSON.parse(response.body)
    end

    def json_slices
      json_response['slices']
    end

    def json_errors
      json_slices[0]
    end

    def document_root_element
      html_document.root
    end

    included do
      metadata[:type] = :api

      before do
        @routes = ::Rails.application.routes
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Rails::ApiExampleGroup, type: :api, file_path: %r{spec/apis}
end

