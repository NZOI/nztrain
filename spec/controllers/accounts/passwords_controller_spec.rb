require 'spec_helper'

describe Accounts::PasswordsController do
  before(:each) do
    @user = users(:user)
  end

  it "can get password reset form" do
    get :new
    expect(response).to be_success
  end

  it "can send password reset email" do
    post :create, :user => {:email => @user.email}

    expect(mail = ActionMailer::Base.deliveries.last).to_not be_nil

    host = ActionMailer::Base.default_url_options[:host]
    expect(mail).to have_link('Change my password')
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
      expect(mail = ActionMailer::Base.deliveries.last).to_not be_nil
      expect(mail.body.encoded =~ %r{<a href=\"http://[[:alnum:]\.\:\/]+/password/edit\?reset_password_token=([^"]+)">}).to_not be_nil
      @reset_token = $1
    end

    it "can edit password" do
      get :edit, :reset_password_token => @reset_token
      expect(response).to be_success
    end

    it "can update password" do
      post :update, :user => {:reset_password_token => @reset_token, :password => "newpassword", :password_confirmation => "newpassword"}
      expect(@resetuser.reload.valid_password?("newpassword")).to be true
    end
  end
end
