class AddOfficalContestants < ActiveRecord::Migration
  def change
    add_column :contests, :only_rank_official_contestants, :boolean, default: false
  end
end
