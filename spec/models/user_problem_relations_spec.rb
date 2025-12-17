require "spec_helper"

describe UserProblemRelation do
  before(:all) do
    @user = FactoryBot.create(:user, username: "contest_score_spec.model.user")
  end
  after(:all) do
    @user.destroy
  end
  context "with subtask scoring" do
    before(:all) do
      @subtask_scoring_problem = FactoryBot.create(:problem, scoring_method: :subtask_scoring) # Uses subtask scoring
      @subtask_one = FactoryBot.create(:test_set, points: 25, problem: @subtask_scoring_problem)
      @subtask_two = FactoryBot.create(:test_set, points: 15, problem: @subtask_scoring_problem)
      @subtask_three = FactoryBot.create(:test_set, points: 60, problem: @subtask_scoring_problem)

      @subtask_one_solution = FactoryBot.create(
        :submission, user: @user, problem: @subtask_scoring_problem, maximum_points: 100, points: 25,
                     judge_log: make_eval_string([[@subtask_one, 1], [@subtask_two, 0], [@subtask_three, 0]])
      )

      @subtask_two_solution = FactoryBot.create(
        :submission, user: @user, problem: @subtask_scoring_problem, maximum_points: 100, points: 15,
                     judge_log: make_eval_string([[@subtask_one, 0], [@subtask_two, 1], [@subtask_three, 0]])
      )
    end

    after(:all) do
      @subtask_two_solution.destroy
      @subtask_one_solution.destroy
      @subtask_three.destroy
      @subtask_two.destroy
      @subtask_one.destroy
      @subtask_scoring_problem.destroy
    end

    it "calculates problem scores correctly" do
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.4)
    end
    it "updates scores correctly when scoring_method changes" do
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.4)
      @subtask_scoring_problem.scoring_method = :max_submission_scoring
      @subtask_scoring_problem.save
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.25)
      @subtask_scoring_problem.scoring_method = :subtask_scoring
      @subtask_scoring_problem.save
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.4)
    end
    it "updates scores correctly when evaluation changes" do
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.4)
      @subtask_one_solution.judge_log = make_eval_string([[@subtask_one, 0.6], [@subtask_two, 2.0 / 3.0], [@subtask_three, 0]]) # Stil comes out to 25 points total
      @subtask_one_solution.save
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.3)
    end
    it "manages unranked submissions correctly" do
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:ranked_score)).to eq(40)
      @subtask_one_solution.classification = Submission::CLASSIFICATION[:unranked]
      @subtask_one_solution.save
      UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:recalculate_and_save) # This won't get automatically updated
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:ranked_score)).to eq(15)
      expect(UserProblemRelation.where(user_id: @user.id, problem_id: @subtask_scoring_problem.id).first.try(:unweighted_score)).to eq(0.4)
    end
  end
end
