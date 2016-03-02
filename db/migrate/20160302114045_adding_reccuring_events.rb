class AddingReccuringEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, null: false, limit: 128
      t.integer :user_id, null: false
      t.date :starts_on
      t.date :ends_on
      t.timestamp :starts_at
      t.timestamp :ends_at
      t.integer :separation, null: false, default: 1
      t.integer :count
      t.date :until
      t.string :timezone_name, null: false, default: 'Etc/UTC'
      t.integer :kind, null: false, default: 0
      t.float :latitude
      t.float :longitude
      t.string :location_name
      t.string :notes, null: false, default: '', limit: 2048
    end

    add_index :events, :user_id
    add_foreign_key :events, :users, :dependent => :cascade

    add_index :events, :kind

    reversible do |dir|
      dir.up do
        remove_foreign_key :notifications_preferences, :calendar_items

        execute <<-SQL
          DROP DOMAIN IF EXISTS frequency CASCADE
        SQL
        execute <<-SQL
          CREATE DOMAIN frequency AS CHARACTER VARYING
            CHECK ( VALUE IN ( 'once', 'daily', 'weekly', 'monthly', 'yearly' ) )
        SQL
        execute <<-SQL
          ALTER TABLE events
            ADD COLUMN frequency frequency
        SQL
        execute <<-SQL
          ALTER TABLE events
            ADD CONSTRAINT positive_separation
              CHECK (separation > 0)
        SQL
        execute <<-SQL
          DELETE FROM notifications_preferences
        SQL

        drop_table :calendar_items
      end

      dir.down do
        create_table :calendar_items do |t|
          t.string :title, null: false, limit: 128
          t.integer :user_id, null: false
          t.datetime :start_date
          t.datetime :end_date
          t.string :notes, null: false, default: '', limit: 2048
          t.string :timezone
          t.integer :kind, null: false, default: 0
          t.float :latitude
          t.float :longitude
          t.string :location_name
        end

        add_foreign_key :notifications_preferences, :calendar_items

        add_index :calendar_items, :user_id
        add_foreign_key :calendar_items, :users, :dependent => :cascade

        add_index :calendar_items, :kind
      end
    end
  end
end
