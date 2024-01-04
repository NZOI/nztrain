class CreateProblemSeries < ActiveRecord::Migration
  def change
    create_table :problem_series do |t|
      t.string :name
      t.string :identifier
      t.string :importer_type
    end
  end
end
