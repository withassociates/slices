require 'spec_helper'

describe PagesHelper, type: :helper do

  describe "#google_analytics_tracking_code" do

    context "when tracking" do
      before do
        helper.stub(add_tracking_code?: true)
      end

      context "tracking one account" do
        let(:tracking) do
          "_gaq.push(['_setAccount', 'ABC132'], ['_trackPageview'], ['_trackPageLoadTime']);"
        end

        subject do
          helper.google_analytics_tracking_code('ABC132')
        end

        it "includes the tracking code" do
          is_expected.to include tracking
        end
      end

      context "tracking multiple accounts" do
        let(:tracking) do
          "_gaq.push(['_setAccount', 'ABC132'], ['_trackPageview'], ['_trackPageLoadTime'], ['b._setAccount', 'DEF546'], ['b._trackPageview'], ['b._trackPageLoadTime']);"
        end

        subject do
          helper.google_analytics_tracking_code('ABC132', 'DEF546')
        end

        it "includes the tracking code" do
          is_expected.to include tracking
        end
      end

      context "tracking no accounts" do
        subject do
          helper.google_analytics_tracking_code(nil)
        end

        it "includes the tracking code" do
          is_expected.to be_nil
        end
      end
    end

    context "when not tracking" do

      before do
        expect(helper).to receive(:add_tracking_code?).and_return(false)
      end

      context "tracking one account" do
        let(:tracking) do
          "_gaq.push(['_setAccount', 'ABC132'], ['_trackPageview'], ['_trackPageLoadTime']);"
        end

        subject do
          helper.google_analytics_tracking_code('ABC132')
        end

        it "tracks nothing" do
          is_expected.to be_nil
        end
      end

    end
  end

  describe "#add_tracking_code?" do

    subject do
      helper.add_tracking_code?
    end

    context "in test mode" do
      it "is false" do
        is_expected.to be_falsey
      end
    end

    context "in production" do
      before do
        Rails.stub_chain(:env, :production?).and_return(true)
      end

      context "not signed in" do
        before do
          expect(helper).to receive(:admin_signed_in?).and_return(false)
        end

        it "is true" do
          is_expected.to be_truthy
        end
      end

      context "signed in" do

        before do
          expect(helper).to receive(:admin_signed_in?).and_return(true)
        end

        it "is false" do
          is_expected.to be_falsey
        end
      end

    end
  end
end

