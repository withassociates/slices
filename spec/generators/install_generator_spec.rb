require 'spec_helper'

describe "slices:install" do
  it "should create an app/slices directory" do
    expect(subject).to generate("app/slices/")
  end

  it "should create a Slices initializer" do
    expect(subject).to generate("config/initializers/slices.rb")
  end

  it "should create an application layout" do
    expect(subject).to generate("app/views/layouts/default.html.erb")
  end

  it "should delete public/index.html" do
    expect(File).to_not be_exist('public/index.html')
  end

  it "should create admin nav partials" do
    expect(subject).to generate("app/views/admin/shared/_custom_navigation.html.erb")
    expect(subject).to generate("app/views/admin/shared/_custom_links.html.erb")
  end
end

