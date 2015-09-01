module Slices
  module HasAttachments
    extend ActiveSupport::Concern

    module ClassMethods

      def has_attachments(embed_name = :attachments, options = {})
        attachment_fields << embed_name
        embeds_many embed_name, {class_name: "Attachment", as: :object}.merge(options)
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
            memo << ::Asset.find(asset_id.to_s)
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

      def remove_asset(asset)
        remove_asset_from_slices(asset)
      end

      def remove_asset_from_slices(asset)
        slices.each { |slice|
          if slice.respond_to?(:remove_asset)
            slice.remove_asset(asset)
          end
        }
      end
    end

    def as_json options = nil
      super.merge(attachments_as_json)
    end

    def attachments_as_json
      self.class.attachment_fields.inject({}) do |hash, name|
        hash[name] = send(name).map(&:as_json)
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

    def remove_asset(asset)
      super if defined?(super)

      asset_id = asset.id.to_s

      self.class.attachment_fields.each do |field_name|
        attachments = attributes[field_name.to_s]
        # Reset field_name so Moped will realise that the field has changed
        self.write_attribute(field_name, [])
        attachments.reject! { |x| x['asset_id'].to_s == asset_id }
        self.write_attribute(field_name, attachments)
      end
    end
  end
end
