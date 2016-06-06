class AddAccountToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :account, :string
  end
end
