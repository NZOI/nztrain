class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name
      t.string :compiler
      t.boolean :is_interpreted

      t.timestamps
    end
  end
end
