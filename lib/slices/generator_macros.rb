module Slices
  module GeneratorMacros
    # Defines a generator method.
    #
    # e.g.
    #
    #     generator :home do
    #       Page.where(path: '/').first || Page.make(
    #         name: 'Home'
    #       )
    #     end
    #
    # Results in:
    #
    #     MyStandardTree.home
    #
    #
    # @param [Symbol] name
    # @param [Proc] block macro body
    #
    def generator name, &block
      define_singleton_method name, &block
      generators << name
    end

    # Simple catalogue of generators.
    def generators
      @generators ||= []
    end

    # Invokes all generators.
    def generate!
      generators.map { |m| send m }
    end
  end
end
