class RemoveSubmissionClassificationDefault < ActiveRecord::Migration
  def up
    change_column :submissions, :classification, :integer, :default => nil
  end

  def down
    change_column :submissions, :classification, :integer, :default => 0
  end
end
