require 'spec_helper'

describe UsersController do
  before(:each) do
    @user = users(:user)
    @superadmin = users(:superadmin)
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :users
    can_show :user
    can_update :user, :attributes => { :name => "A unique name" }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_index :users
  end
end
