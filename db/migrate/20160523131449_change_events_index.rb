class ChangeEventsIndex < ActiveRecord::Migration
  def change
    remove_index :events, :google_event_uniq_id
    add_index :events, :google_event_uniq_id
  end
end
