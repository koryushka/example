class AddListToEvent < ActiveRecord::Migration
  def change
    add_column :events, :list_id, :integer, null: true
    add_index :events, :list_id
    add_foreign_key :events, :lists
  end
end
