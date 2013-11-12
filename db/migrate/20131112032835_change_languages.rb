class ChangeLanguages < ActiveRecord::Migration
  def change
    rename_column :languages, :is_interpreted, :interpreted
    add_column :languages, :flags, :string
  end
end
