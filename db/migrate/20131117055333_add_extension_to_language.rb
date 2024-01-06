class AddExtensionToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :extension, :string, limit: 255
  end
end
