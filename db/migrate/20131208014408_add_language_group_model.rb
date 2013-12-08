class AddLanguageGroupModel < ActiveRecord::Migration
  def change
    create_table :language_groups do |t|
      t.string :identifier
      t.string :name
      t.references :current_language
      t.timestamps
    end

    add_index :language_groups, :identifier, :unique => true

    add_column :languages, :compiled, :boolean

    rename_column :languages, :name, :identifier
    add_column :languages, :name, :string
    add_column :languages, :lexer, :string
    add_column :languages, :group_id, :integer

    add_index :languages, :identifier, :unique => true
  end
end
