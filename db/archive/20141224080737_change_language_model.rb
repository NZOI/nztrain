class ChangeLanguageModel < ActiveRecord::Migration
  def change
    add_column :languages, :source_filename, :string
    add_column :languages, :exe_extension, :string
    add_column :languages, :compiler_command, :string
    add_column :languages, :interpreter, :string
    add_column :languages, :interpreter_command, :string
  end
end
