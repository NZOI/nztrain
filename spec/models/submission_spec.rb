require 'spec_helper'

describe Submission do
  #pending "add some examples to (or delete) #{__FILE__}"
  context 'on "adding" problem' do
    before(:all) do
      @user = FactoryBot.create(:user)
      @problem = FactoryBot.create(:adding_problem)
      @submission = FactoryBot.create(:adding_submission, :problem => @problem, :user => @user)
      @char_submission = FactoryBot.create(:adding_char_submission, :problem => @problem, :user => @user)
      @unsigned_submission = FactoryBot.create(:adding_unsigned_submission, :problem => @problem, :user => @user)
    end
    after(:all) do
      [@user, @problem, @submission, @char_submission, @unsigned_submission].reverse_each { |object| object.destroy }
    end
    it 'judges submission' do
      expect(@submission.score).to be_nil
      @submission.judge
      @submission.reload
      expect(@submission.evaluation).to eq(1)
    end
    it 'judges submission on stdio problem' do
      problem = FactoryBot.create(:adding_problem_stdio)
      submission = FactoryBot.create(:adding_submission_stdio, :problem => problem, :user => @user)
      expect(submission.evaluation).to be_nil
      submission.judge
      submission.reload
      expect(submission.evaluation).to eq(1)
    end
    it 'judges partially correct submissions correctly' do
      expect(@char_submission.score).to be_nil
      @char_submission.judge
      @char_submission.reload
      expect(@char_submission.points).to eq(2)
      expect(@char_submission.maximum_points).to eq(4)

      expect(@unsigned_submission.score).to be_nil
      @unsigned_submission.judge
      @unsigned_submission.reload
      expect(@unsigned_submission.evaluation).to eq(0.75)
    end
  end
end
