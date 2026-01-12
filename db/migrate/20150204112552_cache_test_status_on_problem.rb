class CacheTestStatusOnProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :test_status, :integer, default: 0
  end
end
