class CleanLanguageModel < ActiveRecord::Migration
  def change
    remove_column :languages, :flags, :string
    add_column :languages, :processes, :integer, :default => 1
  end
end
