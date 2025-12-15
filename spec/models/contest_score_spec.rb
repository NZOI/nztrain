require "spec_helper"

describe ContestRelation do
  before(:all) do
    @problem_set = FactoryBot.build(:problem_set)
    @contest = FactoryBot.build(:contest, duration: 5.0, start_time: "01/01/2012 9:00:00", end_time: "01/01/2012 18:00:00", problem_set: @problem_set, finalized_at: nil)
    @user = FactoryBot.create(:user, username: "contest_score_spec.model.user")
    @relation = FactoryBot.create(:contest_relation, contest: @contest, user: @user, started_at: @contest.start_time.advance(hours: 2))
    @problem_stub = FactoryBot.create(:problem, problem_sets: [@problem_set], scoring_method: :max_submission_scoring) # Uses max-submission scoring
    @submission_stub = FactoryBot.create(:submission, user: @user, problem: @problem_stub, maximum_points: 100, points: 14, created_at: @relation.started_at.advance(hours: 1))
    @adding_problem = FactoryBot.create(:adding_problem, problem_sets: [@problem_set], scoring_method: :max_submission_scoring)
    @adding_submission = FactoryBot.create(:adding_submission, user: @user, problem: @adding_problem, created_at: @relation.started_at.advance(hours: 1), maximum_points: 100)
    # @contestscore = FactoryBot.create(:contest_score
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
    expect(ContestScore.where(submission_id: @submission_stub.id).first.try(:score)).to eq(14)
  end
  it "saving change in score updates contest_score" do
    @submission_stub.update_attributes(points: 89)
    expect(ContestScore.where(submission_id: @submission_stub.id).first.try(:score)).to eq(89)
  end
  it "no non-nil scores removes contest_score entry" do
    @submission_stub.update_attributes(points: nil)
    expect(ContestScore.where(submission_id: @submission_stub.id).count).to eq(0)
  end
  it "finds submission with maximum score" do
    FactoryBot.create(:submission, user: @user, problem: @problem_stub, maximum_points: 100, points: 13, created_at: @relation.started_at.advance(hours: 2))
    expect(ContestScore.where(contest_relation_id: @relation.id, problem_id: @problem_stub.id).first.try(:score)).to eq(14)
    FactoryBot.create(:submission, user: @user, problem: @problem_stub, points: 28, maximum_points: 50, created_at: @relation.started_at.advance(hours: 1.5))
    expect(ContestScore.where(contest_relation_id: @relation.id, problem_id: @problem_stub.id).first.try(:score)).to eq(56)
  end
  it "only considers submissions during time when contest_relation is valid" do
    FactoryBot.create(:submission, user: @user, problem: @problem_stub, points: 100, maximum_points: 100, created_at: @relation.started_at.advance(hours: -0.5))
    expect(ContestScore.where(contest_relation_id: @relation.id, problem_id: @problem_stub.id).first.try(:score)).to eq(14)
    FactoryBot.create(:submission, user: @user, problem: @problem_stub, points: 56, maximum_points: 100, created_at: @relation.finish_at.advance(hours: 0.5))
    expect(ContestScore.where(contest_relation_id: @relation.id, problem_id: @problem_stub.id).first.try(:score)).to eq(14)
  end
  it "has automatically updates contest_relation score and time_taken" do
    @relation.reload
    expect(@relation.score).to eq(14)
    expect(@relation.time_taken).to eq(60 * 60)
  end
  it "calculates contest_relation score as sum of contest_score scores" do
    @adding_submission.update_attributes(points: 50)
    @submission_stub.update_attributes(points: 12)
    expect(@relation.reload.score).to eq(62)
  end
  it "calculates contest_relation time_taken as maximum time of contest_score submissions" do
    @adding_submission.update_attributes(points: 10, created_at: @relation.started_at.advance(hours: 3))
    @relation.update_score_and_save
    expect(@relation.reload.time_taken).to eq(3 * 60 * 60)
  end
  it "handles submissions with nil points correctly" do
    @submission_stub.update_attributes(points: nil, evaluation: nil)
    # ContestScore entry should be removed
    expect(ContestScore.where(submission_id: @submission_stub.id).count).to eq(0)
    expect(@relation.reload.score).to eq(0)
  end
  it "handles submissions with zero maximum_points correctly" do
    @submission_stub.update_attributes(points: 0, maximum_points: 0)
    # ContestScore entry should have a score of zero
    expect(ContestScore.where(submission_id: @submission_stub.id).first.try(:score)).to eq(0)
    expect(@relation.reload.score).to eq(0)
  end
  context "with contest finalized" do
    before(:all) do
      @contest.finalized_at = Time.now
      @contest.save
    end
    after(:all) do
      @contest.finalized_at = nil
      @contest.save
    end
    it "does not update contest_score" do
      @adding_submission.update_attributes(points: 50)
      expect(ContestScore.where(submission_id: @adding_submission.id).count).to eq(0)
      @submission_stub.update_attributes(points: 5)
      expect(ContestScore.where(submission_id: @submission_stub.id).first.try(:score)).to eq(14)
    end
    it "does not update contest_relation" do
      @submission_stub.update_attributes(points: 5)
      expect(@relation.reload.score).to eq(14)
    end
  end
  context "with subtask scoring" do
    before(:all) do
      @subtask_scoring_problem = FactoryBot.create(:problem, problem_sets: [@problem_set], scoring_method: :subtask_scoring) # Uses subtask scoring
      @subtask_one = FactoryBot.create(:test_set, points: 25, problem: @subtask_scoring_problem)
      @subtask_two = FactoryBot.create(:test_set, points: 15, problem: @subtask_scoring_problem)
      @subtask_three = FactoryBot.create(:test_set, points: 60, problem: @subtask_scoring_problem)

      @subtask_one_solution = FactoryBot.create(
        :submission, user: @user, problem: @subtask_scoring_problem, created_at: @relation.started_at.advance(hours: 1), maximum_points: 100, points: 25,
                     judge_log: make_eval_string([[@subtask_one, 1], [@subtask_two, 0], [@subtask_three, 0]])
      )

      @subtask_two_solution = FactoryBot.create(
        :submission, user: @user, problem: @subtask_scoring_problem, created_at: @relation.started_at.advance(hours: 1.5), maximum_points: 100, points: 15,
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

    it "calculates subtask scores correctly" do
      expect(ContestScore.where(submission_id: @subtask_two_solution.id).first.try(:score)).to eq(40)
    end
    it "updates scores correctly when scoring_method changes" do
      expect(ContestScore.where(submission_id: @subtask_two_solution.id).first.try(:score)).to eq(40)
      @subtask_scoring_problem.scoring_method = :max_submission_scoring
      @subtask_scoring_problem.save
      expect(ContestScore.where(submission_id: @subtask_one_solution.id).first.try(:score)).to eq(25)
      @subtask_scoring_problem.scoring_method = :subtask_scoring
      @subtask_scoring_problem.save
      expect(ContestScore.where(submission_id: @subtask_two_solution.id).first.try(:score)).to eq(40)
    end
    it "updates scores correctly when evaluation changes" do
      expect(ContestScore.where(submission_id: @subtask_two_solution.id).first.try(:score)).to eq(40)
      @subtask_one_solution.judge_log = make_eval_string([[@subtask_one, 0.6], [@subtask_two, 2.0 / 3.0], [@subtask_three, 0]]) # Stil comes out to 25 points total
      @subtask_one_solution.save
      expect(ContestScore.where(submission_id: @subtask_two_solution.id).first.try(:score)).to eq(30)
    end
  end
end
