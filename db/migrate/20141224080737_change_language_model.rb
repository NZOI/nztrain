class ChangeLanguageModel < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :source_filename, :string, limit: 255
    add_column :languages, :exe_extension, :string, limit: 255
    add_column :languages, :compiler_command, :string, limit: 255
    add_column :languages, :interpreter, :string, limit: 255
    add_column :languages, :interpreter_command, :string, limit: 255
  end
end
