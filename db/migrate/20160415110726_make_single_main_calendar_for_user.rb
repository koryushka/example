class MakeSingleMainCalendarForUser < ActiveRecord::Migration
  def change
    add_column :profiles, :main_calendar_id, :integer, null: true
    add_foreign_key :profiles, :calendars, column: :main_calendar_id, name: 'fk_main_calendar'
    remove_column :calendars, :main, :integer, default: false, null: false
  end
end
