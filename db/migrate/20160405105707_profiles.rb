class Profiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id, null: false
      t.string :full_name, null: false, default: '', limit: 64
      t.string :image_url, limit: 2048
      t.string :color, limit: 6
      t.timestamps
    end

    add_index :profiles, :user_id, unique: true
    add_foreign_key :profiles, :users

    remove_column :users, :user_name, :string, limit: 64
  end
end
