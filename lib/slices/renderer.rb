module Slices
  class Renderer
    include ActiveSupport::Benchmarkable

    def initialize(options = {})
      options.assert_valid_keys(:controller, :current_page, :slices, :params)

      @controller   = options[:controller] || SlicesController.new
      @current_page = options[:current_page]
      @slices       = options[:slices]
      @params       = options[:params] || {}
    end

    def render_slices(slices = @slices)
      [].tap do |rendered|
        slices.each do |slice|
          benchmark "Prepared #{slice.reference}" do
            slice.setup(setup_options)
            slice.prepare(@params)
          end
          rendered << slice.render
        end
      end.join("\n").html_safe
    end

    def render_container(container, slices = @slices)
      render_slices slices.where(container: container)
    end

    def render_to_string(*args)
      @controller.render_to_string(*args)
    end

    def fragment_exist?(cache_key)
      @controller.fragment_exist?(cache_key)
    end

    private

    def setup_options
      {
        renderer:     self,
        current_page: @current_page
      }
    end

    def logger
      Rails.logger
    end
  end
end

