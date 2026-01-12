class AddFilepathToGroupFileAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :group_file_attachments, :filepath, :string, limit: 255

    add_index :group_file_attachments, [:group_id, :filepath]
    add_index :group_file_attachments, :file_attachment_id
  end
end
