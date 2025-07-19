class AddExtensionToLanguage < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :extension, :string, limit: 255
  end
end
