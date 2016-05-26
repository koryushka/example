class AddGoogleAccessTokenToCalendars < ActiveRecord::Migration
  def change
    add_reference :calendars, :google_access_token, index: true, foreign_key: true
  end
end
