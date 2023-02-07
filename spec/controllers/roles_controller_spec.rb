require 'spec_helper'

describe RolesController do
  before(:all) do
    @role = FactoryBot.create(:role)
  end
  after(:all) do
    @role.destroy
  end

  context "as superadmin" do
    before(:each) do
      sign_in users(:superadmin)
    end
    can_index :roles
    can_create :role, :attributes => { :name => "A unique name" }
    can_manage :role, :attributes => { :name => "A unique name" }
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :roles
  end
end
