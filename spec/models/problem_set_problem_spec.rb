require "spec_helper"

describe ProblemSetProblem, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:problem) { FactoryBot.create(:problem, scoring_method: 0) } # Use max-submission scoring
  let(:problem_set) { FactoryBot.create(:problem_set) }

  let(:contest) { FactoryBot.create(:contest, problem_set: problem_set) }
  let(:contest_relation) { FactoryBot.create(:contest_relation, contest: contest, user: user) }
  let!(:contest_score) { FactoryBot.create(:contest_score, contest_relation: contest_relation, problem: problem, score: 100) }
  let!(:submission) { FactoryBot.create(:submission, problem: problem, user: user, created_at: contest_relation.started_at + 1.second, points: 10, maximum_points: 10) }

  subject(:problem_set_problem) { ProblemSetProblem.create!(problem: problem, problem_set: problem_set) }

  describe "#after_save" do
    it "recalculates affected contest scores" do
      problem_set_problem.weighting = 50

      expect { problem_set_problem.save! }
        .to change { contest_score.reload.score }
        .from(100)
        .to(50)
    end
  end
end
