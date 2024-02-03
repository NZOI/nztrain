class AddJobToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :job, :string
  end
end
