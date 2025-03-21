class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name, limit: 255
      t.string :country, limit: 2
      t.integer :users_count
    end
  end
end
