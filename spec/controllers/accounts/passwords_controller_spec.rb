require "spec_helper"

describe Accounts::PasswordsController do
  let(:user) { FactoryBot.create(:user) }

  describe "forgot password" do
    it "can get password reset form" do
      get :new
      expect(response).to be_success
    end

    it "can send password reset email" do
      post :create, user: {email: user.email}

      expect(mail = ActionMailer::Base.deliveries.last).to_not be_nil

      host = ActionMailer::Base.default_url_options[:host]
      expect(mail).to have_link("reset_password_token")
    end
  end

  describe "using password reset token" do
    before do
      @token = user.send_reset_password_instructions
    end

    it "can edit password" do
      get :edit, reset_password_token: @token
      expect(response).to be_success
    end

    it "can update password" do
      post :update, user: {reset_password_token: @token, password: "newpassword", password_confirmation: "newpassword"}

      expect(user.reload.valid_password?("newpassword")).to be true
    end
  end
end
