class CreateSharingPermissions < ActiveRecord::Migration
  def change
    create_table :sharing_permissions do |t|
      t.string :subject_class, length: 64, null: false
      t.string :action, length: 64, null: false
      t.integer :user_id, null: false
    end

    add_foreign_key :sharing_permissions, :users
  end
end
