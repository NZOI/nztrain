require 'test_helper'

class ContestRelationTest < ActiveSupport::TestCase
  # Tests that finish_at is updated at appropriate times
  test "finish_at caching setters and callbacks" do
    def finish_at_correct(relation)
      relation.finish_at == [relation.started_at.advance(:hours => relation.contest.duration),relation.contest.end_time].min
    end
    started_at = contests(:freestart).start_time.advance(:hours => 3)
    relation = ContestRelation.new(:user_id => users(:adminuser).id, :contest_id => contests(:freestart).id, :started_at => started_at)
    assert finish_at_correct relation
    
    relation.started_at = started_at = contests(:freestart).end_time.advance(:hours => -4)
    assert finish_at_correct relation

    assert relation.save # save relation and assert for now
    assert relation.started_at = started_at
    assert finish_at_correct relation

    contest = Contest.new(contests(:freestart).attributes)
    contest.end_time = contest.end_time.advance(:hours => -1)
    contest.save

    relation.contest = contest
    assert finish_at_correct relation # switching contests updates finish_at?
    relation.contest_id = contests(:freestart).id
    assert finish_at_correct relation # contest_id= too?
    
    # test changing attributes of contest, and saving (should trigger relation finish_at updates)
    relation.contest = contest
    contest.end_time = contest.end_time.advance(:hours => -1)
    contest.save
    assert finish_at_correct relation

    contest.duration = 1.0
    contest.save
    assert finish_at_correct relation
    
  end
end
