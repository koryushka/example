class CreateCalendarItems < ActiveRecord::Migration
  def change
    create_table :calendar_items do |t|
      t.string :title, null: false, limit: 128
      t.integer :user_id, null: false
      t.datetime :start_date
      t.datetime :end_date
      t.string :notes, null: false, default: '', limit: 2048
      t.boolean :read_only, null: false, default: false
      t.string :timezone
      t.integer :kind, null: false, default: 0
      t.float :latitude
      t.float :longitude
      t.string :location_name
    end

    add_index :calendar_items, :user_id
    add_foreign_key :calendar_items, :users, :dependent => :cascade

    add_index :calendar_items, :kind

    create_table :calendar_items_calendars do |t|
      t.integer :calendar_id, null: false
      t.integer :calendar_item_id, null: false
    end

    add_index :calendar_items_calendars, [:calendar_id, :calendar_item_id], unique: true, name: 'calendars_calendar_items_main_key'
    add_index :calendar_items_calendars, :calendar_item_id
  end
end
