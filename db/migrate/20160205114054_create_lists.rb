class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :title, null: false, limit: 128
      t.integer :user_id, null: false
      t.string :notes, null: false, default: '', limit: 2048

      t.timestamps null: false
    end

    add_index :lists, :user_id
    add_foreign_key :lists, :users

  end
end
