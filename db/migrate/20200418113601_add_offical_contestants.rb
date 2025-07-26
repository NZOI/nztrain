class AddOfficalContestants < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :only_rank_official_contestants, :boolean, default: false
  end
end
