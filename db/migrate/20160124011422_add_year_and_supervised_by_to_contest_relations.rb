class AddYearAndSupervisedByToContestRelations < ActiveRecord::Migration[4.2]
  def change
    add_column :contest_relations, :school_year, :integer
    add_column :contest_relations, :supervisor_id, :integer
  end
end
