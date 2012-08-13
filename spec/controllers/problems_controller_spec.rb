require 'spec_helper'

describe ProblemsController do

  shared_examples "for any user" do
    can_index :problems
    can_create :problem, :attributes => { :title => "A unique title", :statement => "A unique statement" }
    can_manage :owned_problem, :resource_name => :problem, :attributes => { :title => "A unique title", :statement => "A unique statement" }
  end

  context "as admin" do
    before(:all) do
      @owned_problem = Factory.create(:problem, :owner => users(:admin))
      @unowned_problem = Factory.create(:problem)
    end
    after(:all) do
      @unowned_problem.destroy
      @owned_problem.destroy
    end
    before(:each) do
      sign_in users(:admin)
    end
    include_examples "for any user"
    can_manage :unowned_problem, :resource_name => :problem, :attributes => { :title => "A unique title", :statement => "A unique statement" }
  end

  context "as a normal user" do
    before(:all) do
      @owned_problem = Factory.create(:problem, :owner => users(:user))
      @unowned_problem = Factory.create(:problem)
    end
    after(:all) do
      @unowned_problem.destroy
      @owned_problem.destroy
    end
    before(:each) do
      sign_in users(:user)
    end
    include_examples "for any user"
  end
end
