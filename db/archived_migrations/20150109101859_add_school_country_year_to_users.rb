class AddSchoolCountryYearToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school_id, :integer
    add_column :users, :country_code, :string, limit: 3
    add_column :users, :school_graduation, :date # Year-AnyMonth-00
  end
end
