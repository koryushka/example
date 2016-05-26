class AddCalendarToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :calendar, index: true, foreign_key: true
  end
end
