class AddDefaultLanguageIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_language_id, :integer
  end
end
