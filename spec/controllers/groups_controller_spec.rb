require 'spec_helper'

describe GroupsController do
  before(:all) do
    @group = FactoryGirl.create(:group)
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
    can_browse :groups
  end

  context "as an organiser" do
    before(:each) do
      sign_in users(:organiser)
    end
    can_index :groups, :params => { :filter => 'my' }
  end

end
