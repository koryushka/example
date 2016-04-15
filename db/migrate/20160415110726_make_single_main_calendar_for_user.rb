class MakeSingleMainCalendarForUser < ActiveRecord::Migration
  def change
    add_index :calendars, [:main, :user_id], unique: true
  end
end
