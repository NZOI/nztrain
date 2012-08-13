require 'spec_helper'

describe TestSetsController do
  before(:all) do
    @test_set = Factory.create(:test_set)
  end
  after(:all) do
    @test_set.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :test_sets
    can_create :test_set, :attributes => { :name => "A unique name", :points => 75 }
    can_manage :test_set, :attributes => { :name => "A unique name", :points => 75 }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
  end
end
