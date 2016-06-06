class RemoveEventRecurrencesEventForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key :event_recurrences, :events 
  end
end
