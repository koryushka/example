class AddGoogleEventUniqIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :google_event_uniq_id, :string
    add_index :events, :google_event_uniq_id, unique: true
  end
end
