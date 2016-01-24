class AddYearAndSupervisedByToContestRelations < ActiveRecord::Migration
  def change
    add_column :contest_relations, :school_year, :integer
    add_column :contest_relations, :supervisor_id, :integer
  end
end
