class ChangeCalendarDetails < ActiveRecord::Migration
  def change
    rename_column :calendars, :sync_with_google, :synchronizable
    change_column :calendars, :synchronizable, :boolean, default: true
  end
end
