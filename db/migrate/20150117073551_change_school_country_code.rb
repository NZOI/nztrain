class ChangeSchoolCountryCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :schools, :country, :country_code

    add_column :schools, :synonym_id, :integer # school synonym
  end
end
