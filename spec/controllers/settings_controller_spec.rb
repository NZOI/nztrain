require 'spec_helper'

describe SettingsController do
  before(:all) do
    @setting = FactoryGirl.create(:setting)
  end
  after(:all) do
    @setting.destroy
  end

  context "as superadmin" do
    before(:each) do
      sign_in users(:superadmin)
    end
    can_index :settings
    can_create :setting, :attributes => { :key => "A unique name", :value => "Secret value setting" }
    can_manage :setting, :attributes => { :key => "A unique name", :value => "Secret value setting" }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
  end
end
