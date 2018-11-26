require 'spec_helper'

describe ContestsController do
  before(:all) do
    @problem_set = FactoryBot.create(:problem_set)
    @contest = FactoryBot.create(:contest, :problem_set => @problem_set)
  end
  after(:all) do
    @contest.destroy
  end

  context "as admin" do
    before(:each) do
      sign_in users(:admin)
    end
    can_index :contests
    can_index :contests, :params => { :filter => 'my' }

    can_create :contest, :attributes => { :name => "A unique title", :start_time => "2012-01-01 08:00:00", :end_time => "2012-01-01 18:00:00", :duration => 5.0 }
    can_manage :contest, :attributes => { :name => "A unique title", :start_time => "2012-01-01 08:00:00", :end_time => "2012-01-01 18:00:00", :duration => 5.0 }
  end

  context "as an organiser" do
    before(:each) do
      sign_in users(:organiser)
    end
    can_index :contests, :params => { :filter => 'my' }
  end
end
