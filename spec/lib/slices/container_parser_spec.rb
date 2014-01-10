require 'spec_helper'

describe Slices::ContainerParser, ".parse" do

  let(:container_parser) do
    path = Rails.root.join('spec/fixtures/views/layouts', layout + '.html.erb')
    Slices::ContainerParser.new(path)
  end

  subject { container_parser.parse.symbolize_keys }

  context "one container" do
    let(:layout) { 'one_container' }

    it { should == {
      body: { name: 'Body' }
    } }
  end

  context "two containers, with options" do
    let(:layout) { 'layout_with_container_options' }

    it { should == {
      container_one: { name: 'Container One', only: [:title, :you_tube] },
      container_two: { name: 'Container Two', primary: true, except: [:lunch_choice] },
    } }
  end

  context "two containers with a yield" do
    let(:layout) { 'layout_yield' }

    it { should == {
      container_one: { name: 'Container One' },
      container_two: { name: 'Container Two' },
    } }
  end
end

