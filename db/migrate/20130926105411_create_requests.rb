class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :requester
      t.references :object, :polymorphic => true
      t.string :verb, :null => false
      t.references :subject, :null => false, :polymorphic => true
      t.integer :status, :null => false, :default => 0
      t.references :requestee
      t.datetime :expired_at, :null => false, :default => :infinity
 
      t.timestamps
    end
  end
end
