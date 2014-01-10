require 'spec_helper'

describe "Administering Admins", js: true do
  before do
    sign_in_as_admin
  end

  context "viewing the index with lots of admins" do
    before do
      51.times do |n|
        Admin.create!(
          name: "Admin#{n}",
          email: "a#{n}@example.com",
          password: 'testing',
        )
      end
      visit '/admin/admins'
    end

    it "shows 50 on the index page" do
      page.should have_css 'tbody tr', count: 50
    end

    it "has links to edit an admin" do
      admin = Admin.all.second
      page.should have_link admin.name, href: admin_admin_path(admin.id)
    end

    context "viewing the second page" do
      before do
        js_click_on '#pagination li:last-child a'
      end

      it "displays 12 admins" do
        page.should have_css 'tbody tr', count: 2
      end
    end

  end

  context "viewing the index with 2 admins" do
    before do
      Admin.create!(
        name: 'Jamie White',
        email: 'jamie@jgwhite.co.uk',
        password: 'ilovejam'
      )

      visit '/admin/admins'
    end

    it "displays two admins" do
      page.should have_css 'tbody tr', count: 2
    end

    it "does not display a delete button for me" do
      page.should have_css 'tbody tr', text: 'This is you'
      page.should have_css 'tbody tr .delete', count: 1
    end

    context "when an admin is deleted" do
      before do
        js_click_on 'tbody tr:last-child a.delete'
      end

      it "is removed from the page" do
        page.should_not have_css 'tbody tr', text: 'Jamie White'
        page.should have_css 'tbody tr', count: 1
      end

      it "is really deleted" do
        sleep 0.2
        page.should_not have_css 'tbody tr', text: 'Jamie White'
        page.should have_css 'tbody tr', count: 1
      end
    end
  end

  context "creating an admin" do
    before do
      visit '/admin/admins'
      js_click_on '#add-admin'
    end

    context "without errors" do
      before do
        fill_in 'Name', with: 'Courage Wolf'
        fill_in 'Email', with: 'courage@threewolves.com'
        fill_in 'Password', with: 'tusconmilk'
        fill_in 'Password confirmation', with: 'tusconmilk'
        click_button 'Save'
      end

      it "adds it to the index page" do
        page.should have_css 'tbody tr', count: 2
        page.should have_content 'Courage Wolf'
      end
    end

    context "with errors" do
      before do
        fill_in 'Name', with: 'Fail'
        click_button 'Save'
      end

      it "shows an error" do
        page.should have_css 'li.error', count: 2
      end
    end
  end

  context "editing an admin" do
    before do
      visit '/admin/admins'
      click_link 'No Name Set'
    end

    context "is updated with no errors" do
      before do
        fill_in 'Name', with: 'Maru'
        click_button 'Save'
      end

      it "updates the name" do
        find_field('Name').value.should == 'Maru'
      end

      it "updates with no errors" do
        page.should have_no_css 'li.error'
      end
    end
  end
end
