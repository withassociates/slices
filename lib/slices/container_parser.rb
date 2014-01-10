module Slices
  class ContainerParser
    class MissingLayoutError < StandardError; end

    def initialize(path)
      raise MissingLayoutError if path.nil?
      @path = path
      @containers = {}
    end

    def parse
      @page = Page.new
      erb_template = File.read(@path)
      @erb = ActionView::Template::Handlers::Erubis.new(erb_template)
      parse_with_block {}
      @containers
    end

    # Define a +container+ in a layout, a container holds slices on a page.
    #
    # This container is called Title and only allows title and You Tube slices
    #
    #   container "title", :only => [TitleSlice, YouTubeSlice]
    #
    # Here's a container called body which is the primary and does not allow
    # title slices.
    #
    #   container "body", :primary => true, :except => TitleSlice
    #
    # @param  [String]     name                               Name of container
    # @param  [Hash]       options
    # @option options [Boolean] :primary (false)              Is this container the primary
    # @option options [Class,Array] :except                   Disallow these slice(s) from this container
    # @option options [Class,Array] :only                     Only allow these slice(s) from this container
    # @return [String]
    #
    def container(name, options = {})
      [:except, :only].each do |type|
        if options.has_key? type
          options[type] = convert_slice_classes_to_symbols(options[type])
        end
      end

      @containers[name] = options.reverse_merge name: name.titleize
    end

    def method_missing(meth, *args, &block)
      yield if block_given?
    end

    private

    def parse_with_block(&block)
      @erb.result(binding)
    end

    def convert_slice_classes_to_symbols(options = [])
      [options].flatten.select do |klass|
        klass.is_a?(Class)
      end.map do |klass|
        convert_slice_class_to_symbol(klass)
      end
    end

    def convert_slice_class_to_symbol(klass)
      klass.name.underscore.split('_')[0 .. -2].join('_').to_sym
    end
  end
end

