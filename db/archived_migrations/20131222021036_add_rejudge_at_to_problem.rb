class AddRejudgeAtToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :rejudge_at, :timestamp

    reversible do |dir|
      dir.up do
        execute 'UPDATE problems SET rejudge_at = updated_at'
      end
    end
  end
end
