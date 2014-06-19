require 'spec_helper'

describe Slices::Renderer do

  let :rendered_container_one do
    "<h1>Title</h1>\n"
  end

  let :rendered_container_two do
    "<h2>Textile</h2>"
  end

  let :page do
    StandardTree.build_minimal_with_slices.last
  end

  let :slices do
    page.ordered_slices
  end

  context "with slices defined in setup" do
    let :renderer do
      Slices::Renderer.new({
        current_page: page,
        slices: slices
      })
    end

    it "renders container one" do
      expect(renderer.render_container('container_one')).to eq rendered_container_one
    end

    it "renders container two" do
      expect(renderer.render_container('container_two')).to eq rendered_container_two
    end
  end

  context "with slices passed in" do
    let :renderer do
      Slices::Renderer.new({
        current_page: page
      })
    end

    it "renders container one" do
      expect(renderer.render_container('container_one', slices)).to eq rendered_container_one
    end

    it "renders container two" do
      expect(renderer.render_container('container_two', slices)).to eq rendered_container_two
    end
  end

  context "without specifying a container" do
    let :renderer do
      Slices::Renderer.new({
        current_page: page,
        slices: slices
      })
    end

    let :expected do
      [rendered_container_one, rendered_container_two].join "\n"
    end

    it "renders all slices" do
      expect(renderer.render_slices).to eq expected
    end
  end
end

