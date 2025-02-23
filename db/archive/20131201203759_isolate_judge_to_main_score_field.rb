class IsolateJudgeToMainScoreField < ActiveRecord::Migration
  def up
    execute "UPDATE submissions SET score = isolate_score;"

    Contest.all.each do |contest|
      if contest.finalized_at.nil?
        contest.finalized_at = Time.now
        contest.save
      end
    end

    remove_column :submissions, :isolate_score
    remove_column :submissions, :judge_output
    remove_column :submissions, :debug_output
  end

  def down
    add_column :submissions, :debug_output, :text
    add_column :submissions, :judge_output, :text
    add_column :submissions, :isolate_score, :integer
  end
end
