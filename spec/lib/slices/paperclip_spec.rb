require 'spec_helper'

describe Paperclip::Interpolations do

  describe "#fingerprint_partition" do
    it "partitions a BSON id" do
      fingerprint = '40235deba79ee4734d6034bf05688a5b'
      instance = double(:instance, fingerprint: fingerprint)
      attachment = double(:attachment, fingerprint: fingerprint)

      Paperclip::Interpolations.fingerprint_partition(attachment, :original).
        should eq('402/35deba79ee4734d6034bf05688a5b')
    end
  end
end
