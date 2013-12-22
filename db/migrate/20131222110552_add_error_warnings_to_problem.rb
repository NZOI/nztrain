class AddErrorWarningsToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :test_error_count, :integer, default: 0
    add_column :problems, :test_warning_count, :integer, default: 0

    # used for errors and warnings
    add_column :submissions, :test_errors, :string, array: true
    add_column :submissions, :test_warnings, :string, array: true
  end
end
