require 'rails_helper'

RSpec.describe 'User Profile workflow', type: :feature do
  describe 'loads user profile' do
    context 'as the user' do
      it 'shows all profile data and link to edit profile data' do
        user = create(:user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit profile_path

        expect(page).to have_content("Profile Page for #{user.name}")
        expect(page).to have_content(user.email)
        within '#address' do
          expect(page).to have_content(user.address)
          expect(page).to have_content("#{user.city}, #{user.state} #{user.zip}")
        end
        expect(page).to have_link('Edit Profile')
        expect(page).to have_link('My Orders')
      end
    end
  end
  describe 'allows profile editing' do
    context 'as the user' do
      it 'edits profile data when data is properly entered' do
        user = create(:user, email: 'a@b.com', password: 'password')
        visit login_path
        fill_in :email, with: 'a@b.com'
        fill_in :password, with: 'password'
        click_button 'Log in'

        visit profile_edit_path

        email = "email_2@gmail.com"
        name = "Ian Douglas 2"
        address = "123 Main St 2"
        city = "Denver 2"
        state = "CO 2"
        zip = "80000 2"

        fill_in :user_email,	with: email
        fill_in :user_password,	with: "new_password"
        fill_in :user_password_confirmation,	with: "new_password"
        fill_in :user_name,	with: name
        fill_in :user_address,	with: address
        fill_in :user_city,	with: city
        fill_in :user_state,	with: state
        fill_in :user_zip,	with: zip
        click_button 'Update User'

        user_check = User.find(user.id)
        expect(user_check.password_digest).to_not eq(user.password_digest)

        expect(current_path).to eq(profile_path)
        expect(page).to have_content("Profile Page for #{user_check.name}")
        expect(page).to have_content(user_check.email)
        within '#address' do
          expect(page).to have_content(user_check.address)
          expect(page).to have_content("#{user_check.city}, #{user_check.state} #{user_check.zip}")
        end
        expect(page).to have_content('Profile data updated')

        visit logout_path
        visit login_path
        fill_in :email, with: email
        fill_in :password, with: 'new_password'
        click_button 'Log in'
        expect(current_path).to eq(profile_path)
      end
      it 'edits profile data when data is properly entered and password is missing' do
        user = create(:user, email: 'a@b.com', password: 'password')
        visit login_path
        fill_in :email, with: 'a@b.com'
        fill_in :password, with: 'password'
        click_button 'Log in'

        visit profile_edit_path

        email = "email_2@gmail.com"
        name = "Ian Douglas 2"
        address = "123 Main St 2"
        city = "Denver 2"
        state = "CO 2"
        zip = "80000 2"

        fill_in :user_email,	with: email
        fill_in :user_name,	with: name
        fill_in :user_address,	with: address
        fill_in :user_city,	with: city
        fill_in :user_state,	with: state
        fill_in :user_zip,	with: zip
        click_button 'Update User'

        user_check = User.find(user.id)
        expect(user_check.password_digest).to eq(user.password_digest)

        expect(current_path).to eq(profile_path)
        expect(page).to have_content("Profile Page for #{user_check.name}")
        expect(page).to have_content(user_check.email)
        within '#address' do
          expect(page).to have_content(user_check.address)
          expect(page).to have_content("#{user_check.city}, #{user_check.state} #{user_check.zip}")
        end
        expect(page).to have_content('Profile data updated')
      end
    end
  end
  describe 'blocks profile editing' do
    scenario 'when email is not unique' do
      create(:user, email: 'unique@gmail.com')
      user = create(:user, email: 'ian@gmail.com')
      visit login_path
      fill_in :email, with: 'ian@gmail.com'
      fill_in :password, with: 'password'
      click_button 'Log in'

      visit profile_edit_path

        fill_in :user_email,	with: 'unique@gmail.com'
        click_button 'Update User'

        expect(current_path).to eq(user_path(user))
        expect(page).to have_content('Profile update failed')
        expect(page).to have_content('Email has already been taken')
      end
  end
end