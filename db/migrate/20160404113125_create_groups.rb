class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title, null: false, default: '', limit: 128
      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_index :groups, :user_id
    add_foreign_key :groups, :users

    create_table :groups_users do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false
    end

    add_index :groups_users, [:group_id, :user_id], unique: true
    add_index :groups_users, :user_id

    add_foreign_key :groups_users, :groups
    add_foreign_key :groups_users, :users
  end
end
