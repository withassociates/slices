require 'spec_helper'
require 'generators/slices/install_generator'

describe Slices::InstallGenerator do
  destination Rails.root.join('tmp')

  before do
    prepare_destination
    run_generator
  end

  it "should create an app/slices directory" do
    expect(file("app/slices/")).to exist
  end

  it "should create a Slices initializer" do
    expect(file("config/initializers/slices.rb")).to exist
  end

  it "should create an application layout" do
    expect(file("app/views/layouts/default.html.erb")).to exist
  end

  it "should delete public/index.html" do
    expect(file('public/index.html')).not_to exist
  end

  it "should create admin nav partials" do
    expect(file("app/views/admin/shared/_custom_navigation.html.erb")).to exist
    expect(file("app/views/admin/shared/_custom_links.html.erb")).to exist
  end
end

