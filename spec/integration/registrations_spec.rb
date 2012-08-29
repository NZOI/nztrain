require 'spec_helper'

feature 'registration' do
  scenario 'register as a new user, confirm, sign out and sign-in with registration password' do
    visit '/accounts/sign_in'
    find(:xpath, "//a[@href='/accounts/sign_up']").click
    within 'form#new_user' do
      fill_in 'Username', :with => 'registration_username'
      fill_in 'Name', :with => 'Registration Name'
      fill_in 'Email', :with => 'registration@integration.spec'
      fill_in 'Password', :with => 'registration password'
      fill_in 'Password confirmation', :with => 'registration password'
      click_on 'Sign up'
    end
    (mail = ActionMailer::Base.deliveries.last).should_not be_nil
    mail.to.should == ['registration@integration.spec'] # confirmation email sent to right place

    @user = User.find_by_username('registration_username')
    @user.confirmed?.should be_false
    visit "/accounts/confirmation?confirmation_token=#{@user.confirmation_token}"
    @user.reload.confirmed?.should be_true # make sure new user account is confirmed

    visit '/'
    # we should be signed in
    find('#current_user_username').text.should == 'registration_username'

    find('#sign_out').click # after signing out,
    page.should have_selector('#sign_in') # should see a sign_in link

    find('#sign_in').click

    within 'form#new_user' do
      fill_in 'user_email', :with => 'registration_username'
      fill_in 'user_password', :with => 'registration password'
      click_on 'Sign in'
    end

    find('#current_user_username').text.should == 'registration_username' # we should be signed in
  end
end
