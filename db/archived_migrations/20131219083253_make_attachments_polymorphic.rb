class MakeAttachmentsPolymorphic < ActiveRecord::Migration
  def up
    rename_table :group_file_attachments, :filelinks
    rename_column :filelinks, :group_id, :root_id
    add_column :filelinks, :root_type, :string, limit: 255

    drop_table :problem_file_attachments

    execute "UPDATE filelinks SET root_type='Group'"
  end

  def down
    create_table :problem_file_attachments do |t|
      t.references :problem
      t.references :file_attachment
    end

    remove_column :filelinks, :root_type
    rename_column :filelinks, :root_id, :group_id
    rename_table :filelinks, :group_file_attachments
  end
end
