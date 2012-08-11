require 'test_helper'

class ContestScoreTest < ActiveSupport::TestCase
  setup do
    relation = ContestRelation.where(:user => users(:normal_user), :contest => contests(:contestscore))
    assert relation.first.score == 0
  end

  test "the truth" do
    assert true
  end

  test "scores only during contest relation" do
    Submission.new(submissions(:sub2beforecontest).merge(:))
  end
end
