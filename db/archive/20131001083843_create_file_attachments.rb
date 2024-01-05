class CreateFileAttachments < ActiveRecord::Migration
  def change
    create_table :file_attachments do |t|
      t.string :name
      t.string :file_attachment, :string
      t.references :owner

      t.timestamps null: false
    end

    create_table :group_file_attachments do |t|
      t.references :group
      t.references :file_attachment

      t.timestamp :created_at
    end

    create_table :problem_file_attachments do |t|
      t.references :problem
      t.references :file_attachment
    end
  end
end
