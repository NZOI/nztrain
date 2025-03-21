class AddJobToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :job, :string, limit: 255
  end
end
