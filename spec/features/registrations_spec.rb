require 'spec_helper'

feature 'registration' do
  scenario 'register as a new user, confirm, sign out and sign-in with registration password' do
    visit '/accounts/sign_in'
    find(:xpath, "//a[@href='/accounts/sign_up']").click
    within 'form#new_user' do
      fill_in 'Username', :with => 'registration_username'
      fill_in 'Name', :with => 'Registration Name'
      fill_in 'Email', :with => 'registration@integration.spec'
      fill_in 'user_password', :with => 'registration password'
      fill_in 'Password confirmation', :with => 'registration password'
      click_on 'Sign up'
    end
    mail = open_email('registration@integration.spec')
    expect(mail.to).to eq(['registration@integration.spec'])
    expect(mail).to have_link("Confirm")

    @user = User.find_by_username('registration_username')
    expect(@user.confirmed?).to be false
    mail.click_link("Confirm")
    visit "/accounts/confirmation?confirmation_token=#{@user.confirmation_token}"
    expect(@user.reload.confirmed?).to be true # make sure new user account is confirmed

    visit '/accounts/sign_in'
    # sign in
    within 'form#new_user' do
      fill_in :user_email, :with => 'registration@integration.spec'
      fill_in :user_password, :with => 'registration password'
      click_on 'Sign in'
    end

    # we should be signed in
    expect(find('#current_user_username').text).to eq('registration_username')

    find('#sign_out').click # after signing out,
    expect(page).to have_selector('#sign_in') # should see a sign_in link

    find('#sign_in').click

    within 'form#new_user' do
      fill_in 'user_email', :with => 'registration_username'
      fill_in 'user_password', :with => 'registration password'
      click_on 'Sign in'
    end

    expect(find('#current_user_username').text).to eq('registration_username') # we should be signed in
  end
end
