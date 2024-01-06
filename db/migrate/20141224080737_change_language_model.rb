class ChangeLanguageModel < ActiveRecord::Migration
  def change
    add_column :languages, :source_filename, :string, limit: 255
    add_column :languages, :exe_extension, :string, limit: 255
    add_column :languages, :compiler_command, :string, limit: 255
    add_column :languages, :interpreter, :string, limit: 255
    add_column :languages, :interpreter_command, :string, limit: 255
  end
end
