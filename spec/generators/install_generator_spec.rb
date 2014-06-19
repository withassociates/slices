# -*- encoding: utf-8 -*-

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
    expect(File.exist?("public/index.html")).not_to be_truthy
  end
end

