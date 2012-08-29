require 'spec_helper'

describe TestCasesController do
  before(:all) do
    @test_case = FactoryGirl.create(:test_case, :test_set => test_sets(:test_set))
  end
  after(:all) do
    @test_case.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :test_cases
    #can_manage :test_case, :attributes => { :name => "A unique name", :input => "Some secret judging data", :output => "The unguessable answer" }
    can_show :test_case
    can_destroy :test_case
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
  end
end
