require "spec_helper"

describe UserController do
  before(:each) do
    @user = users(:user)
    @superadmin = users(:superadmin)
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_show :user
    can_update :user, attributes: {name: "A unique name"}
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_show :user
  end
end
