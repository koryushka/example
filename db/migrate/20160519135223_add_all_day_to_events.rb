class AddAllDayToEvents < ActiveRecord::Migration
  def change
    add_column :events, :all_day, :boolean, null: false, default: false
  end
end
