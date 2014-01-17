# -*- encoding: utf-8 -*-

require 'spec_helper'

describe "slices:install" do
  it "creates an app/slices directory" do
    subject.should generate("app/slices/")
  end

  it "creates a Slices initializer" do
    subject.should generate("config/initializers/slices.rb")
  end

  it "creates an application layout" do
    subject.should generate("app/views/layouts/default.html.erb")
  end

  it "deletes public/index.html" do
    File.exist?("public/index.html").should_not be_true
  end
end
