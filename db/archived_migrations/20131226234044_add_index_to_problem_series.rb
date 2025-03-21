class AddIndexToProblemSeries < ActiveRecord::Migration
  def change
    add_column :problem_series, :index_yaml, :text
  end
end
