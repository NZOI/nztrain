class AddLanguageGroupModel < ActiveRecord::Migration
  def change
    create_table :language_groups do |t|
      t.string :identifier, limit: 255
      t.string :name, limit: 255
      t.references :current_language
      t.timestamps null: false
    end

    add_index :language_groups, :identifier, unique: true

    add_column :languages, :compiled, :boolean

    rename_column :languages, :name, :identifier
    add_column :languages, :name, :string, limit: 255
    add_column :languages, :lexer, :string, limit: 255
    add_column :languages, :group_id, :integer

    add_index :languages, :identifier, unique: true
  end
end
