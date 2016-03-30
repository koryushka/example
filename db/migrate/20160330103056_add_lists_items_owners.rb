class AddListsItemsOwners < ActiveRecord::Migration
  def change
    ListItem.delete_all

    add_column :list_items, :user_id, :integer, null: false
    add_index :list_items, :user_id
    add_foreign_key :list_items, :users
  end
end
