class CreateProblemSeries < ActiveRecord::Migration
  def change
    create_table :problem_series do |t|
      t.string :name
      t.string :identifier
      t.string :importer_type
    end

    # unused column
    remove_column :file_attachments, :string, :string
  end
end
