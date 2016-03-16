class RenameEventsRenameEventsTable < ActiveRecord::Migration
  def change
    reversible do |rev|
      rev.up do
        rename_table :events_documents, :documents_events
      end
      rev.down do
        rename_table :documents_events, :events_documents
      end
    end
  end
end
