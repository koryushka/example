class AddNotificationTimeToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :notification_time, :integer, null: false, default: 30
  end
end
