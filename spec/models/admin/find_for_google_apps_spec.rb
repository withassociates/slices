require 'spec_helper'

describe Admin, "#find_for_google_apps" do

  it "finds the admin" do
    admin = Admin.create!(email: 'erin@example.com', password: 123456)
    Admin.find_for_google_apps('erin@example.com').should eq admin
  end

  it "finds the first admin for the domain" do
    Slices::Config.should_receive(:google_apps_domain).and_return('example.com')
    admin = Admin.create!(email: 'hello@example.com', password: 123456)
    Admin.find_for_google_apps('erin@example.com').should eq admin
  end
end
