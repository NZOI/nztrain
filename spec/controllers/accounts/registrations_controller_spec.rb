require 'spec_helper'

describe Accounts::RegistrationsController do
  it "can get signup form" do
    get :new
    response.should be_success
  end

  it 'can signup (create action)' do
    expect do
      post :create, :user => { :username => "signup_username", :name => "Mr. SignUp", :email => "signup@nztrain.com", :password => "password", :password_confirmation => "password" }
    end.to change{User.count}.by(1)
    # check signup attributes saved
    newuser = User.find_by_username("signup_username")
    newuser.should_not be_nil
    newuser.name.should == "Mr. SignUp"
    newuser.email.should == "signup@nztrain.com"
    newuser.valid_password?("password").should be_true
    # check email confirmation email sent
    (mail = ActionMailer::Base.deliveries.last).should_not be_nil
    mail.to.should == ["signup@nztrain.com"] # email sent to right place
    expect(mail).to have_link('Confirm') # email includes confirmation link
  end

  context 'when signed in' do
    before(:all) do
      @user = FactoryGirl.create(:user, :password => "registration password")
    end
    after(:all) do
      @user.destroy
    end
    before(:each) do
      sign_in @user
    end

    it "can get edit password form" do
      get :edit, :type => "password"
      response.should be_success
    end

    it "can get edit email form" do
      get :edit, :type => "email"
      response.should be_success
    end
  end

  context 'when signed in' do
    before(:each) do
      @user = FactoryGirl.create(:user, :password => "registration password")
      sign_in @user
    end
    after(:each) do
      @user.destroy
    end

    it "can update password" do
      put :update, :type => "password", :user => { :password => "anewpass", :password_confirmation => "anewpass", :current_password => "registration password" }
      @user.reload.valid_password?("anewpass").should be_true
    end

    it "can update email" do
      put :update, :type => "email", :user => { :email => "unconfirmed@nztrain.com", :current_password => "registration password" }
      @user.reload.unconfirmed_email.should == "unconfirmed@nztrain.com"

      expect(mail = ActionMailer::Base.deliveries.last).to_not be_nil
      expect(mail.to).to eq ["unconfirmed@nztrain.com"] # email sent to right place
      expect(mail.body.encoded =~ %r{<a href=\"http://[[:alnum:]\.\:\/]+\?confirmation_token=([^"]+)">}).to_not be_nil
    end
  end
end
