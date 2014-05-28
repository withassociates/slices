module Slices
  module HasSlices
    extend ActiveSupport::Concern

    included do
      validate :validate_slices
    end

    module ClassMethods
      def has_slices(embed_name)
        embeds_many embed_name, class_name: 'Slice', validate: false
        accepts_nested_attributes_for embed_name, allow_destroy: true

        class_attribute :slice_embeds if self == Page
        if slice_embeds.nil?
          self.slice_embeds = [embed_name]
        else
          self.slice_embeds = slice_embeds + [embed_name]
        end

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def ordered_#{embed_name}             # def orderd_slices
            #{embed_name}.ascending(:position)  #   slices.ascending(:position)
          end                                   # end
        RUBY
      end
    end

    def update_attributes(attributes)
      [:slices, :set_slices].each do |type|
        next if attributes[type].nil?

        attributes[type] = attributes[type].map { |slice|
          slice = slice.symbolize_keys
          next if slice[:_destroy]
          slice.delete :_new
          (slice[:type] + '_slice').
            camelize.
            constantize.
            new(slice).tap do |s|
              s.id = slice[:id] if slice[:id].present?
            end
        }.compact
      end

      super
    end

    def slices_for(embed_name)
      send(embed_name)
    end

    def ordered_slices_for(embed_name=nil)
      embed_name = self.class.slice_embeds.first if embed_name.nil?
      send("ordered_#{embed_name}")
    end

    def validate_slices
      embeded_slices do |embed_name|
        _slice_errors = slice_errors_for(embed_name)
        if _slice_errors.any?
          errors.add(embed_name, _slice_errors)
        end
      end
    end

    def slice_errors_for(embed_name)
      Hash.new.tap do |message|
        slices_for(embed_name).each do |slice|
          if ! slice.valid? && ! slice.to_delete?
            message[slice.id_or_client_id] = messages_from_errors(slice.errors)
          end
        end
      end
    end

    def embeded_slices(&block)
      self.class.slice_embeds.each do |embed_name|
        yield(embed_name)
      end
    end

    def messages_from_errors(errors)
      if errors.respond_to?(:messages)
        errors.messages
      else
        errors
      end
    end

  end
end
