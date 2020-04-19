require 'spec_helper'

describe Submission do
  #pending "add some examples to (or delete) #{__FILE__}"
  context 'on "adding" problem' do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @problem = FactoryGirl.create(:adding_problem)
      @submission = FactoryGirl.create(:adding_submission, :problem => @problem, :user => @user)
      @char_submission = FactoryGirl.create(:adding_char_submission, :problem => @problem, :user => @user)
      @unsigned_submission = FactoryGirl.create(:adding_unsigned_submission, :problem => @problem, :user => @user)
    end
    after(:all) do
      [@user, @problem, @submission, @char_submission, @unsigned_submission].reverse_each { |object| object.destroy }
    end
    it 'judges submission' do
      @submission.score.should be_nil
      @submission.judge
      @submission.reload
      @submission.evaluation.should == 1
    end
    it 'judges submission on stdio problem' do
      problem = FactoryGirl.create(:adding_problem_stdio)
      submission = FactoryGirl.create(:adding_submission_stdio, :problem => problem, :user => @user)
      submission.evaluation.should be_nil
      submission.judge
      submission.reload
      submission.evaluation.should == 1
    end
    it 'judges partially correct submissions correctly' do
      @char_submission.score.should be_nil
      @char_submission.judge
      @char_submission.reload
      @char_submission.points.should == 2
      @char_submission.maximum_points.should == 4

      @unsigned_submission.score.should be_nil
      @unsigned_submission.judge
      @unsigned_submission.reload
      @unsigned_submission.evaluation.should == 0.75
    end
  end
end
