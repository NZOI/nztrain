require 'spec_helper'

describe ProblemSetsController do
  before(:all) do
    @problem_set = Factory.create(:problem_set)
  end
  after(:all) do
    @problem_set.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :problem_sets
    can_create :problem_set, :attributes => { :title => "A unique title" }
    can_manage :problem_set, :attributes => { :title => "A unique title" }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_index :problem_sets
  end
end
