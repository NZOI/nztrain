class CreateItemsAndProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :entities do |t|
      t.string :name, limit: 255
      # replaces `t.references :entity, polymorphic: true` to add limit: 255
      t.integer :entity_id
      t.string :entity_type, limit: 255
    end
    create_table :organisations do |t|
    end
    create_table :products do |t|
      t.string :name, limit: 255
      t.integer :gtin, limit: 8
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
