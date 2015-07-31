require 'spec_helper'

describe Admin, type: :model do
  describe "#as_json" do

    let :admin do
      Admin.new(
        name: 'Admin User',
        email: 'hello@withassociates.com',
        password: '123456',
        super_user: false,
        last_sign_in_at: Time.new(2000)
      )
    end

    let :other_admin do
      Admin.new(
        email: 'erin@withassociates.com',
        password: '123456'
      )
    end

    it "is serialized" do
      expect(admin.as_json).to eq({
        _id: admin.id.to_s,
        name: 'Admin User',
        email: "hello@withassociates.com",
        current_admin: false,
        last_sign_in_at: Time.new(2000),
        super_user: false,
      })
    end

    context "when a current_admin is passed as an option" do

      it "sets the current_admin to true" do
        expect(admin.as_json(current_admin: admin)).to include ({current_admin: true})
      end

      it "sets the current_admin to false" do
        expect(admin.as_json(current_admin: other_admin)).to include ({current_admin: false})
      end
    end

  end
end
