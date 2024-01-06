class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :requester
      # replaces `t.references :subject, polymorphic: true` to add limit: 255
      t.integer :subject_id
      t.string :subject_type, limit: 255
      t.string :verb, limit: 255, null: false
      # replaces `t.references :target, null: false, polymorphic: true` to add limit: 255
      t.integer :target_id, null: false
      t.string :target_type, limit: 255, null: false
      t.integer :status, null: false, default: 0
      t.references :requestee
      t.datetime :expired_at, null: false, default: :infinity

      t.timestamps null: false
    end
  end
end
