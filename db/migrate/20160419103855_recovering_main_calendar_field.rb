class RecoveringMainCalendarField < ActiveRecord::Migration
  def change
    add_column :calendars, :main, :boolean, default: false, null: false
  end
end
