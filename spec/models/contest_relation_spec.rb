require 'spec_helper'

describe ContestRelation do
  include FixturesSpecHelper
  RSpec::Matchers.define :finish_at_correct_time do
    def expected_time(relation)
      [relation.started_at.advance(:hours => relation.contest.duration),relation.contest.end_time].min
    end
    match do |relation|
      relation.finish_at == expected_time(relation)
    end
    failure_message do |relation|
      "expected finishing at #{expected_time(relation)}, got finish_at #{relation.finish_at}"
    end
    failure_message_when_negated do |relation|
      "expected not finishing at #{expected_time(relation)}, got finish_at #{relation.finish_at}"
    end
    description do
      "finish at the earlier of when contest duration runs out or when contest finishes"
    end
  end
  before(:all) do
    @contest = FactoryGirl.create(:contest)
    @relation = FactoryGirl.create(:contest_relation, :contest => @contest, :user => users(:user))
  end
  after(:all) do
    @relation.destroy
    @contest.destroy
  end
  it "updates finish_at when relation started_at changes" do
    expect(@relation).to finish_at_correct_time
    @relation.started_at = @contest.end_time.advance(:hours => -1)
    expect(@relation).to finish_at_correct_time
  end
  it "updates finish_at when contest changes" do
    @anothercontest = FactoryGirl.build(:contest, :start_time => @relation.started_at.advance(:hours => -1), :end_time => @relation.started_at.advance(:hours => 1))
    @relation.contest = @anothercontest
    expect(@relation).to finish_at_correct_time
    @relation.contest_id = @contest.id
    expect(@relation).to finish_at_correct_time
  end
  it "updates finish_at when contest end_time changes" do
    @contest.update_attributes(:end_time => @relation.started_at.advance(:hours => 1))
    expect(@relation).to finish_at_correct_time
  end
  it "updates finish_at when contest duration changes" do
    @contest.update_attributes(:duration => 1.0)
    expect(@relation).to finish_at_correct_time
    @contest.update_attributes(:duration => 5.0)
    expect(@relation).to finish_at_correct_time
  end

end
