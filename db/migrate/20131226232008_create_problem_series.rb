class CreateProblemSeries < ActiveRecord::Migration[4.2]
  def change
    create_table :problem_series do |t|
      t.string :name, limit: 255
      t.string :identifier, limit: 255
      t.string :importer_type, limit: 255
    end
  end
end
