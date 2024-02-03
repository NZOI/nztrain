class CreateItemsAndProducts < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :name
      t.references :entity, :polymorphic => true
    end
    create_table :organisations do |t|
    end
    create_table :products do |t|
      t.string :name
      t.integer :gtin, :limit => 8
    end
    create_table :items do |t|
      t.references :product
      t.references :owner # entity
      t.references :organisation # system of items
      t.references :sponsor # entity that paid for the item
      t.integer :condition
      t.integer :status
    end
    create_table :item_histories do |t|
      t.references :item
      t.boolean :active
      t.integer :action
      t.references :holder # entity
    end
  end
end
