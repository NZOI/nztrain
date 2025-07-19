class CreateLanguages < ActiveRecord::Migration[4.2]
  def change
    create_table :languages do |t|
      t.string :name, limit: 255
      t.string :compiler, limit: 255
      t.boolean :is_interpreted

      t.timestamps null: false
    end
  end
end
