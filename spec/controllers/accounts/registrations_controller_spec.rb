require 'spec_helper'

describe Accounts::RegistrationsController do
  it "can get signup form" do
    get :new
    expect(response).to be_success
  end

  it 'can signup (create action)' do
    expect do
      post :create, :user => { :username => "signup_username", :name => "Mr. SignUp", :email => "signup@nztrain.com", :password => "password", :password_confirmation => "password" }
    end.to change{User.count}.by(1)
    # check signup attributes saved
    newuser = User.find_by_username("signup_username")
    expect(newuser).not_to be_nil
    expect(newuser.name).to eq("Mr. SignUp")
    expect(newuser.email).to eq("signup@nztrain.com")
    expect(newuser.valid_password?("password")).to be true
    # check email confirmation email sent
    expect(mail = ActionMailer::Base.deliveries.last).not_to be_nil
    expect(mail.to).to eq(["signup@nztrain.com"]) # email sent to right place
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
      expect(response).to be_success
    end

    it "can get edit email form" do
      get :edit, :type => "email"
      expect(response).to be_success
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
      expect(@user.reload.valid_password?("anewpass")).to be true
    end

    it "can update email" do
      put :update, :type => "email", :user => { :email => "unconfirmed@nztrain.com", :current_password => "registration password" }
      expect(@user.reload.unconfirmed_email).to eq("unconfirmed@nztrain.com")

      expect(mail = ActionMailer::Base.deliveries.last).to_not be_nil
      expect(mail.to).to eq ["unconfirmed@nztrain.com"] # email sent to right place
      expect(mail.body.encoded =~ %r{<a href=\"http://[[:alnum:]\.\:\/]+\?confirmation_token=([^"]+)">}).to_not be_nil
    end
  end
end
