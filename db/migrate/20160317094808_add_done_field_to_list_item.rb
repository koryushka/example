class AddDoneFieldToListItem < ActiveRecord::Migration
  def change
    add_column :list_items, :done, :boolean, null: false, default: false
  end
end
