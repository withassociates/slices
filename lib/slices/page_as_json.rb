module Slices
  # We keep this method in here to facilate easier overriding when re-opening Page.
  module PageAsJSON
    include Slices::LocalizedFields

    def as_json(options = {})
      options ||= {}

      hash = Slices::Serialization.for_json(self).except('author_id', 'set_slices').merge(
        'slices' => ordered_slices_for(options[:slice_embed]).map {|slice| slice.as_json },
        'permalink' => permalink,
        'available_layouts' => available_layouts
      )

      if author
        hash['author'] = { 'id' => author.id.to_s, 'name' => author.name }
      end
      localized_field_names.each do |name|
        hash.merge!(name => send(name))
      end

      keys = options['only']
      keys ? hash.slice(keys) : hash
    end
  end
end
