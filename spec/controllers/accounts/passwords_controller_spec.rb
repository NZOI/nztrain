require 'spec_helper'

describe Accounts::PasswordsController do
  before(:each) do
    @user = users(:user)
  end

  it "can get password reset form" do
    get :new
    response.should be_success
  end

  it "can send password reset email" do
    post :create, :user => {:email => @user.email}

    (mail = ActionMailer::Base.deliveries.last).should_not be_nil

    host = ActionMailer::Base.default_url_options[:host]
    reset_url_regexp = Regexp.escape "<a href=\"http://#{host}#{edit_user_password_path :reset_password_token => @user.reload.reset_password_token}\">"
    mail.body.encoded.should match reset_url_regexp
  end
  context "using password reset token" do
    before(:all) do
      @resetuser = FactoryGirl.create(:user)
    end
    after(:all) do
      @resetuser.destroy
    end
    before(:each) do
      User.send_reset_password_instructions :email => @resetuser.email
      @resetuser.reload
    end

    it "can edit password" do
      get :edit, :reset_password_token => @resetuser.reset_password_token
      response.should be_success
    end

    it "can update password" do
      post :update, :user => {:reset_password_token => @resetuser.reset_password_token, :password => "newpassword", :password_confirmation => "newpassword"}
      @resetuser.reload.valid_password?("newpassword").should be_true
    end
  end
end
