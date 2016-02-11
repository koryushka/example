class CreateNotificationsPreferences < ActiveRecord::Migration
  def change
    create_table :notifications_preferences do |t|
      t.boolean :email, null: false, default: false
      t.boolean :push, null: false, default: false
      t.boolean :sms, null: false, default: false
      t.integer :calendar_item_id, null: false
    end

    add_index :notifications_preferences, :calendar_item_id
    add_foreign_key :notifications_preferences, :calendar_items

  end
end
