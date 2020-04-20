class AddOfficalCompetitors < ActiveRecord::Migration
    def change
      add_column :contests, :show_unofficial_competitors, :boolean, :default => false
    end
  end
