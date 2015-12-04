require 'spec_helper'

describe "Administering Admins", type: :request, js: true do
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
      expect(page).to have_css 'tbody tr', count: 50
    end

    it "has links to edit an admin" do
      admin = Admin.all.second
      expect(page).to have_link admin.name, href: admin_admin_path(admin.id)
    end

    context "viewing the second page" do
      before do
        js_click_on '#pagination li:last-child a'
      end

      it "displays 12 admins" do
        expect(page).to have_css 'tbody tr', count: 2
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
      expect(page).to have_css 'tbody tr', count: 2
    end

    it "does not display a delete button for me" do
      expect(page).to have_css 'tbody tr', text: 'This is you'
      expect(page).to have_css 'tbody tr .delete', count: 1
    end

    context "when an admin is deleted" do
      before do
        js_click_on 'a.delete'
      end

      it "is removed from the page" do
        expect(page).to have_css 'tbody tr', count: 1
        expect(page).to have_no_css 'tbody tr', text: 'Jamie White'
      end

      it "is really deleted on reload" do
        page.visit current_path
        expect(page).to have_css 'tbody tr', count: 1
        expect(page).to have_no_css 'tbody tr', text: 'Jamie White'
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
        click_button 'Save'
      end

      it "adds it to the index page" do
        expect(page).to have_css 'tbody tr', count: 2
        expect(page).to have_content 'Courage Wolf'
      end
    end

    context "with errors" do
      before do
        fill_in 'Name', with: 'Fail'
        click_button 'Save'
      end

      it "shows an error" do
        expect(page).to have_css 'li.error', count: 2
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
        expect(find_field('Name').value).to eq('Maru')
      end

      it "updates with no errors" do
        expect(page).to have_no_css 'li.error'
      end
    end
  end
end
