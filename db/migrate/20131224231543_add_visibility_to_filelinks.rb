class AddVisibilityToFilelinks < ActiveRecord::Migration[4.2]
  def change
    add_column :filelinks, :visibility, :integer, limit: 1, default: 0
  end
end
