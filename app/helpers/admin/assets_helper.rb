# This module provides helper methods for assets in the CMS admin.
# #
module Admin::AssetsHelper
  include Admin::AdminHelper

  # Sign policy with S3 credentials
  #
  # @!visibility private
  def signature(options = {})
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        Slices::Config.s3_credentials[:secret_access_key],
        policy({ secret_access_key: Slices::Config.s3_credentials[:secret_access_key] })
      )
    ).gsub(/\n/, '')
  end

  # Generate policy for uploading asset direct to S3
  #
  # @!visibility private
  def policy(options = {})
    Base64.encode64(
      {
        expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        conditions: [
          { bucket: Slices::Config.s3_credentials[:bucket] },
          { acl: 'public-read' },
          { success_action_status: '201' },
          ['starts-with', '$key', ''],
          ['starts-with', '$Content-Type', ''],
        ]
      }.to_json
    ).gsub(/\n|\r/, '')
  end
end
