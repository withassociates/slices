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
      [:slices, :set_slices].each do |embed_name|
        next if attributes[embed_name].nil?

        attributes[embed_name] = attributes[embed_name].map { |slice_attributes|
          slice_attributes = slice_attributes.symbolize_keys
          next if slice_attributes[:_destroy]
          slice_attributes.delete :_new

          if slice_attributes[:id].present?
            slice = slices_for(embed_name).find(slice_attributes[:id])
            slice.write_attributes(slice_attributes)
          else
            class_name = slice_attributes[:type].to_s.camelize + 'Slice'
            slice = class_name.constantize.new(slice_attributes)
          end
          slice
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
