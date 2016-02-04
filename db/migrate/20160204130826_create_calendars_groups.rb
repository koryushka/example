class CreateCalendarsGroups < ActiveRecord::Migration
  def change
    create_table :calendars_groups do |t|
      t.string :title
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :calendars_groups, :user_id
    add_foreign_key :calendars_groups, :users

    create_table :calendars_calendars_groups do |t|
      t.integer :calendar_id
      t.integer :calendars_group_id
    end

    add_index :calendars_calendars_groups, [:calendar_id, :calendars_group_id], unique: true, name: 'calendars_calendars_groups_main_key'
    add_index :calendars_calendars_groups, :calendars_group_id
  end
end
