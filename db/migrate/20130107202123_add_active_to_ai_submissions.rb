class AddActiveToAiSubmissions < ActiveRecord::Migration
  def change
    add_column :ai_submissions, :active, :boolean, :default => false
  end
end
