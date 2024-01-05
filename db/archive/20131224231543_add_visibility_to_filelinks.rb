class AddVisibilityToFilelinks < ActiveRecord::Migration
  def change
    add_column :filelinks, :visibility, :integer, limit: 1, default: 0
  end
end
