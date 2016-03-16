class AddListType < ActiveRecord::Migration
  def change
    add_column :lists, :kind, :integer, limit: 1
  end
end
