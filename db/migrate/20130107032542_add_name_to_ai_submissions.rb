class AddNameToAiSubmissions < ActiveRecord::Migration
  def change
    add_column :ai_submissions, :name, :string
  end
end
