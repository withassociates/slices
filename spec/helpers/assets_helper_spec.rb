require 'spec_helper'

describe AssetsHelper, type: :helper do
  use_extended_style

  let :asset do
    double(:asset,
        present?: true,
        ).as_null_object
  end

  let :image_url do
    '/media/ladybird.jpg'
  end

  context "#image_if_present" do

    it "is nil with a missing image" do
      expect(image_if_present(nil, :foo)).to be_nil
    end

    it "is nil when given an invalid size" do
      expect(image_if_present(asset, :foobarbaz)).to be_nil
    end

    it "has a valid image tag custom size" do
      expect(asset).to receive(:dimensions_for).with(:extended).and_return('80x60')
      expect(asset).to receive(:url_for).with(:extended).and_return(image_url)

      image = image_if_present(asset, :extended)
      expect(image).to have_xpath('//img[@height="60"]')
      expect(image).to have_xpath('//img[@width="80"]')
    end

    context "with :admin size" do
      before do
        expect(asset).to receive(:dimensions_for).with(:admin).and_return('180x180')
        expect(asset).to receive(:url_for).with(:admin).and_return(image_url)
      end

      it "has a valid image tag" do
        image = image_if_present(asset, :admin)
        expect(image).to have_xpath('//img[@src="/media/ladybird.jpg"]')
        expect(image).to have_xpath('//img[@height="180"]')
        expect(image).to have_xpath('//img[@width="180"]')
      end

      it "has a valid image tag for string sizes" do
        image = image_if_present(asset, 'admin')
        expect(image).to have_xpath('//img[@src="/media/ladybird.jpg"]')
        expect(image).to have_xpath('//img[@height="180"]')
        expect(image).to have_xpath('//img[@width="180"]')
      end

      it "includes additional properties passed" do
        expect(image_if_present(asset, :admin, 'data-foo' => 'bar')).to have_xpath('//img[@data-foo="bar"]')
      end

      it "allows custom alt attributes" do
        expect(image_if_present(asset, :admin, alt: 'bar')).to have_xpath('//img[@alt="bar"]')
      end

    end

    context "with an attachement" do
      let :attachement do
        double(:attachement,
             asset: asset
            )
      end

      it "has a valid image tag custom size" do
        expect(asset).to receive(:dimensions_for).with(:extended).and_return('80x60')
        expect(asset).to receive(:url_for).with(:extended).and_return(image_url)

        image = image_if_present(attachement, :extended)
        expect(image).to have_xpath('//img[@height="60"]')
        expect(image).to have_xpath('//img[@width="80"]')
      end

    end
  end

  context "#link_image_if_linkable" do

    it "is nil when passed a nil link and a nil image" do
      expect(link_image_if_linkable(nil, nil, :admin)).to be_nil
    end

    it "is nil when passed a nil image" do
      expect(link_image_if_linkable("/foo/bar", nil, :admin)).to be_nil
    end

    context "with :admin image size" do

      before do
        expect(asset).to receive(:dimensions_for).with(:admin).and_return('180x180')
        expect(asset).to receive(:url_for).with(:admin).and_return(image_url)
      end

      it "is an image if there is no link" do
        image = link_image_if_linkable(nil, asset, :admin)
        expect(image).to have_xpath("//img[@src='#{image_url}']")
      end

      it "is a linked image if both are passsed" do
        image = link_image_if_linkable('/foo/bar', asset, :admin)
        expect(image).to have_xpath("//img[@src='#{image_url}']")
        expect(image).to have_xpath("//a[@href='/foo/bar']")
      end

      it "allow options on the link" do
        image = link_image_if_linkable("/foo/bar", asset, :admin, class: "baz")
        expect(image).to have_xpath("//a[@class='baz']")
      end

      it "allows options on the image as well" do
        image = link_image_if_linkable("/foo/bar", asset, :admin, class: "arc", image_options: {class: "otter"})
        expect(image).to have_xpath("//a[@class='arc']")
        expect(image).to have_xpath("//img[@class='otter']")
      end
    end
  end

end

