class AddGoogleCalendarIdToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :google_calendar_id, :string
  end
end
