class AddJudgeOutputToSubmissions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :submissions, :judge_output, :text
  end

  def self.down
    remove_column :submissions, :judge_output
  end
end
