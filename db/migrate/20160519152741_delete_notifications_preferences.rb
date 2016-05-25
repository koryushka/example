class DeleteNotificationsPreferences < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        drop_table :notifications_preferences
      end
      dir.down do
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
  end
end
