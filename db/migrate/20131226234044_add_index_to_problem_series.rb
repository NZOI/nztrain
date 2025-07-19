class AddIndexToProblemSeries < ActiveRecord::Migration[4.2]
  def change
    add_column :problem_series, :index_yaml, :text
  end
end
