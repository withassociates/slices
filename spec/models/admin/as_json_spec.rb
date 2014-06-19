require 'spec_helper'

describe Admin, type: :model do
  describe "#as_json" do

    let :admin do
      Admin.new(
        email: 'hello@withassociates.com',
        password: '123456'
      )
    end

    let :other_admin do
      Admin.new(
        email: 'erin@withassociates.com',
        password: '123456'
      )
    end

    context "when a current_admin is passed as an option" do

      it "sets the current_admin to true" do
        expect(admin.as_json(current_admin: admin)).to include ({current_admin: true})
      end

      it "sets the current_admin to false" do
        expect(admin.as_json(current_admin: other_admin)).to include ({current_admin: false})
      end
    end

    context "when no current_admin is passed" do

      it "does not add a current_admin key" do
        expect(admin.as_json({}).keys).not_to include :current_admin
      end
    end

  end
end
