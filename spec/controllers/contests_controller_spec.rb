require 'spec_helper'

describe ContestsController do
  before(:all) do
    @problem_set = FactoryGirl.create(:problem_set)
    @contest = FactoryGirl.create(:contest, :problem_set => @problem_set)
  end
  after(:all) do
    @contest.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :contests

    can_create :contest, :attributes => { :title => "A unique title", :start_time => "2012-01-01 08:00:00", :end_time => "2012-01-01 18:00:00", :duration => 5.0 }
    can_manage :contest, :attributes => { :title => "A unique title", :start_time => "2012-01-01 08:00:00", :end_time => "2012-01-01 18:00:00", :duration => 5.0 }
  end

  context "as a normal user" do
    before(:each) do
      sign_in users(:user)
    end
    can_index :contests
  end
end
