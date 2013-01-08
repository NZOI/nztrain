class AddIterationsToAiContests < ActiveRecord::Migration
  def change
    add_column :ai_contests, :iterations, :integer
    add_column :ai_contests, :iterations_preview, :integer
  end
end
