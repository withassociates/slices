# -*- encoding: utf-8 -*-

require 'spec_helper'

describe "slices:install" do

  around do |example|
    dummy = File.expand_path('spec/dummy')
    Dir.mktmpdir { |dir|
      FileUtils.cp_r(dummy, dir)
      Dir.chdir(File.expand_path('dummy', dir)) {
        run_generator "slices:install --force"
        example.run
      }
    }
  end

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

  it "should make ApplicationController inherit from SlicesController" do
    expect("app/controllers/application_controller.rb").to contain <<-CONTENT
      class ApplicationController < SlicesController
    CONTENT
  end
end

