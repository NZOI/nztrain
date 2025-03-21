class AddDebugToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :debug_output, :text
  end
end
