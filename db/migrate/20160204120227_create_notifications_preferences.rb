class CreateNotificationsPreferences < ActiveRecord::Migration
  def change
    create_table :notifications_preferences do |t|
      t.boolean :email, null: false, default: false
      t.boolean :push, null: false, default: false
      t.boolean :sms, null: false, default: false
    end

    change_table :calendars do |t|
      t.integer :notifications_preference_id, null: false
    end

    add_index :calendars, :notifications_preference_id
    add_foreign_key :calendars, :notifications_preferences

    change_table :calendar_items do |t|
      t.integer :notifications_preference_id, null: false
    end

    add_index :calendar_items, :notifications_preference_id
    add_foreign_key :calendar_items, :notifications_preferences
  end
end
