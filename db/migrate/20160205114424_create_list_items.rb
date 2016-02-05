class CreateListItems < ActiveRecord::Migration
  def change
    create_table :list_items do |t|
      t.string :title, null: false, limit: 128
      t.string :notes, null: false, default: '', limit: 2048
      t.integer :order, null: false, default: 0
      t.integer :list_id, null: false

      t.timestamps null: false
    end

    add_index :list_items, :list_id
    add_foreign_key :list_items, :lists
  end
end
