class AddOfficalContestants < ActiveRecord::Migration
    def change
      add_column :contests, :show_unofficial_contestants, :boolean, :default => false
    end
  end
