class AddRecurringEventIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :recurring_event_id, :integer
  end
end
