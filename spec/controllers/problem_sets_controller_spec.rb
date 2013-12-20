require 'spec_helper'

describe ProblemSetsController do
  before(:all) do
    @problem_set = FactoryGirl.create(:problem_set)
  end
  after(:all) do
    @problem_set.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :problem_sets
    can_create :problem_set, :attributes => { :name => "A unique title" }
    can_manage :problem_set, :attributes => { :name => "A unique title" }
  end

  context "as an organiser" do
    before(:each) do
      sign_in users(:organiser)
    end
    can_index :problem_sets, :params => { :filter => 'my' }
  end
end
