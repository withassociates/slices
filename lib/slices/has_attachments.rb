module Slices
  module HasAttachments
    extend ActiveSupport::Concern

    module ClassMethods

      def has_attachments(embed_name = :attachments, options = {})
        klass = if options.has_key?(:class_name)
                  options[:class_name].constantize
                else
                  Attachment
                end

        default = options[:default] || options[:singular] ? nil : []
        type = options[:singular] ? Hash : Array

        if options[:singular]
          define_method embed_name do
            if embed = read_attribute(embed_name)
              klass.new embed
            end
          end
        else
          define_method embed_name do
            (read_attribute(embed_name) || []).collect do |embed|
              klass.new embed
            end
          end
        end

        attachment_fields << embed_name

        field embed_name, type: type, default: default
      end

      def attachment_fields
        @attachment_fields ||= if superclass.respond_to?(:attachment_fields)
                                 superclass.attachment_fields.dup
                               else
                                 []
                               end
      end

    end

    module PageInstanceMethods

      def attachment_assets
        attachment_asset_ids.inject([]) do |memo, asset_id|
          begin
            memo << ::Asset.find(asset_id)
          rescue Mongoid::Errors::DocumentNotFound
          end
          memo
        end
      end

      def slice_attachment_asset_ids
        [].tap do |asset_ids|
          self.class.slice_embeds.each do |slice_embed|
            slices_for(slice_embed).each do |slice|
              if slice.respond_to? :attachment_asset_ids
                asset_ids.concat slice.attachment_asset_ids
              end
            end
          end
        end
      end
      alias :attachment_asset_ids :slice_attachment_asset_ids

    end

    def as_json options = nil
      super.merge(attachments_as_json)
    end

    def attachments_as_json
      self.class.attachment_fields.inject({}) do |hash, name|
        value = send name

        hash[name] = if value.respond_to?(:map)
                       value.map &:as_json
                     else
                       value.as_json
                     end

        hash
      end
    end

    def attachment_asset_ids
      _attachment_asset_ids.tap do |asset_ids|
        if respond_to? :slice_attachment_asset_ids
          asset_ids.concat slice_attachment_asset_ids
        end
        asset_ids.uniq!
      end
    end

    def _attachment_asset_ids
      attachment_asset_ids = self.class.attachment_fields.collect do |attachments|
        [send(attachments)].flatten.collect do |attachment|
          attachment.asset_id
        end.reject {|i| i.nil? }
      end.flat_map {|i| i }
    end

  end

end

