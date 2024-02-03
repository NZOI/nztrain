class AddExtensionToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :extension, :string
  end
end
