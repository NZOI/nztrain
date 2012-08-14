require 'spec_helper'

describe ContestRelation do
  before(:all) do
    @problem_set = Factory.build(:problem_set)
    @contest = Factory.build(:contest, :duration => 5.0, :start_time => "01/01/2012 9:00:00", :end_time => "01/01/2012 18:00:00", :problem_set => @problem_set, :finalized_at => nil)
    @user = Factory.create(:user)
    @relation = Factory.create(:contest_relation, :contest => @contest, :user => @user, :started_at => @contest.start_time.advance(:hours => 2))
    @problem_stub = Factory.create(:problem, :problem_sets => [@problem_set])
    @submission_stub = Factory.create(:submission, :user => @user, :problem => @problem_stub, :score => 14, :created_at => @relation.started_at.advance(:hours => 1))
    @adding_problem = Factory.create(:adding_problem, :problem_sets => [@problem_set])
    @adding_submission = Factory.create(:adding_submission, :user => @user, :problem => @adding_problem, :created_at => @relation.started_at.advance(:hours => 1))
    #@contestscore = Factory.create(:contest_score
  end
  after(:all) do
    @adding_submission.destroy
    @adding_problem.destroy
    @submission_stub.destroy
    @problem_stub.destroy
    @relation.destroy
    @user.destroy
    @contest.destroy
    @problem_set.destroy
  end
  it "adds contest_score entry on create" do # from before(:all) block variable @submission_stub
    ContestScore.where(:submission_id => @submission_stub.id).first.try(:score).should == 14
  end
  it "saving change in score updates contest_score" do
    @submission_stub.update_attributes(:score => 89)
    ContestScore.where(:submission_id => @submission_stub.id).first.try(:score).should == 89
  end
  it "no non-nil scores removes contest_score entry" do
    @submission_stub.update_attributes(:score => nil)
    ContestScore.where(:submission_id => @submission_stub.id).count.should == 0
  end
  it "finds submission with maximum score" do
    Factory.create(:submission, :user => @user, :problem => @problem_stub, :score => 13, :created_at => @relation.started_at.advance(:hours => 2))
    ContestScore.where(:contest_relation_id => @relation.id, :problem_id => @problem_stub.id).first.try(:score).should == 14
    Factory.create(:submission, :user => @user, :problem => @problem_stub, :score => 56, :created_at => @relation.started_at.advance(:hours => 1.5))
    ContestScore.where(:contest_relation_id => @relation.id, :problem_id => @problem_stub.id).first.try(:score).should == 56
  end
  it "only considers submissions during time when contest_relation is valid" do
    Factory.create(:submission, :user => @user, :problem => @problem_stub, :score => 100, :created_at => @relation.started_at.advance(:hours => -0.5))
    ContestScore.where(:contest_relation_id => @relation.id, :problem_id => @problem_stub.id).first.try(:score).should == 14
    Factory.create(:submission, :user => @user, :problem => @problem_stub, :score => 56, :created_at => @relation.finish_at.advance(:hours => 0.5))
    ContestScore.where(:contest_relation_id => @relation.id, :problem_id => @problem_stub.id).first.try(:score).should == 14
  end
  it "has automatically updates contest_relation score and time_taken" do
    @relation.reload
    @relation.score.should == 14
    @relation.time_taken.should == 60*60
  end
  it "calculates contest_relation score as sum of contest_score scores" do
    @adding_submission.update_attributes(:score => 50)
    @submission_stub.update_attributes(:score => 12)
    @relation.reload.score.should == 62
  end
  it "calculates contest_relation time_taken as maximum time of contest_score submissions" do
    @adding_submission.update_attributes(:score => 10, :created_at => @relation.started_at.advance(:hours => 3))
    @relation.update_score_and_save
    @relation.reload.time_taken.should == 3*60*60
  end
  context "with contest finalized" do
    before(:all) do
      @contest.finalized_at = Time.now
      @contest.save
    end
    after(:all) do
      @contest.finalized_at = nil
    end
    it "does not update contest_score" do
      @adding_submission.update_attributes(:score => 50)
      ContestScore.where(:submission_id => @adding_submission.id).count.should == 0
      @submission_stub.update_attributes(:score => 5)
      ContestScore.where(:submission_id => @submission_stub.id).first.try(:score).should == 14
    end
    it "does not update contest_relation" do
      @submission_stub.update_attributes(:score => 5)
      @relation.reload.score.should == 14
    end
  end
end
