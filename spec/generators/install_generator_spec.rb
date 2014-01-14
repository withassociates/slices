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
    subject.should generate("app/views/layouts/application.html.erb")
  end
end
