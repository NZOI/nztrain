class ChangeLanguages < ActiveRecord::Migration[4.2]
  def change
    rename_column :languages, :is_interpreted, :interpreted
    add_column :languages, :flags, :string, limit: 255
  end
end
