class CacheTestStatusOnProblem < ActiveRecord::Migration
  def change
    add_column :problems, :test_status, :integer, default: 0
  end
end
