class AddSyncWithGoogleToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :sync_with_google, :boolean, default: true
  end
end
