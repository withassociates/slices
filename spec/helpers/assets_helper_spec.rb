require 'spec_helper'

describe AssetsHelper do
  use_extended_style

  let :asset do
    stub(:asset,
        present?: true,
        ).as_null_object
  end

  let :image_url do
    '/media/ladybird.jpg'
  end

  context "#image_if_present" do

    it "is nil with a missing image" do
      image_if_present(nil, :foo).should be_nil
    end

    it "is nil when given an invalid size" do
      image_if_present(asset, :foobarbaz).should be_nil
    end

    it "has a valid image tag custom size" do
      asset.should_receive(:dimensions_for).with(:extended).and_return('80x60')
      asset.should_receive(:url_for).with(:extended).and_return(image_url)

      expected_html = %Q{<img alt="Ladybird" height="60" src="#{image_url}" width="80" />}
      image_if_present(asset, :extended).should eq expected_html
    end

    context "with :admin size" do
      before do
        asset.should_receive(:dimensions_for).with(:admin).and_return('180x180')
        asset.should_receive(:url_for).with(:admin).and_return(image_url)
      end

      it "has a valid image tag" do
        expected_html = %Q{<img alt="Ladybird" height="180" src="#{image_url}" width="180" />}
        image_if_present(asset, :admin).should eq expected_html
      end

      it "has a valid image tag for string sizes" do
        expected_html = %Q{<img alt="Ladybird" height="180" src="#{image_url}" width="180" />}
        image_if_present(asset, 'admin').to_s.should eq expected_html
      end

      it "includes additional properties passed" do
        expected_html = %Q{<img alt="Ladybird" data-foo="bar" height="180" src="#{image_url}" width="180" />}
        image_if_present(asset, :admin, 'data-foo' => 'bar').should eq expected_html
      end

      it "allows custom alt attributes" do
        expected_html = %Q{<img alt="Ladybird" data-foo="bar" height="180" src="#{image_url}" width="180" />}
        image_if_present(asset, :admin, 'data-foo' => 'bar').should eq expected_html
      end

    end

    context "with an attachement" do
      let :attachement do
        stub(:attachement,
             asset: asset
            )
      end

      it "has a valid image tag custom size" do
        asset.should_receive(:dimensions_for).with(:extended).and_return('80x60')
        asset.should_receive(:url_for).with(:extended).and_return(image_url)

        expected_html = %Q{<img alt="Ladybird" height="60" src="#{image_url}" width="80" />}
        image_if_present(attachement, :extended).should eq expected_html
      end

    end
  end

  context "#link_image_if_linkable" do

    it "is nil when passed a nil link and a nil image" do
      link_image_if_linkable(nil, nil, :admin).should be_nil
    end

    it "is nil when passed a nil image" do
      link_image_if_linkable("/foo/bar", nil, :admin).should be_nil
    end

    context "with :admin image size" do

      before do
        asset.should_receive(:dimensions_for).with(:admin).and_return('180x180')
        asset.should_receive(:url_for).with(:admin).and_return(image_url)
      end

      it "is an image if there is no link" do
        expected_html = %Q{<img alt="Ladybird" height="180" src="#{image_url}" width="180" />}
        link_image_if_linkable(nil, asset, :admin).should eq expected_html
      end

      it "is a linked image if both are passsed" do
        expected_html = %Q{<a href="/foo/bar"><img alt="Ladybird" height="180" src="#{image_url}" width="180" /></a>}
        link_image_if_linkable("/foo/bar", asset, :admin).should eq expected_html
      end

      it "allow options on the link" do
        expected_html = %Q{<a href="/foo/bar" class="baz"><img alt="Ladybird" height="180" src="#{image_url}" width="180" /></a>}
        link_image_if_linkable("/foo/bar", asset, :admin, class: "baz").should eq expected_html
      end

      it "allows options on the image as well" do
        expected_html = %Q{<a href="/foo/bar" class="arc"><img alt="Ladybird" class="otter" height="180" src="#{image_url}" width="180" /></a>}
        link_image_if_linkable("/foo/bar", asset, :admin, class: "arc", image_options: {class: "otter"}).should eq expected_html
      end
    end
  end

end

