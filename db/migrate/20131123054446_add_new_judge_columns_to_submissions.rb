class AddNewJudgeColumnsToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :judge_log, :text
    add_column :submissions, :isolate_score, :integer
    add_column :submissions, :judged_at, :timestamp
  end
end
