class SetDefaultSharingAction < ActiveRecord::Migration
  def up
    change_column :sharing_permissions, :action, :string, length: 64, null: false, default: ''
  end

  def down
    change_column :sharing_permissions, :action, :string, length: 64, null: false
  end
end
