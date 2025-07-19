class AddDebugToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :debug_output, :text
  end
end
