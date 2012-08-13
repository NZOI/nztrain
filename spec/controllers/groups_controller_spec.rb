require 'spec_helper'

describe GroupsController do
  before(:all) do
    @group = Factory.create(:group)
  end
  after(:all) do
    @group.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :groups
    can_create :group, :attributes => { :name => "A unique name" }
    can_manage :group, :attributes => { :name => "A unique name" }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_index :groups
  end
end
