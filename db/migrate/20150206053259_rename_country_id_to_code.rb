class RenameCountryIdToCode < ActiveRecord::Migration[4.2]
  def change
    remove_column :contest_relations, :country_id, :integer
    add_column :contest_relations, :country_code, :string, limit: 2
  end
end
