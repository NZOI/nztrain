class AddJobToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :job, :string, limit: 255
  end
end
