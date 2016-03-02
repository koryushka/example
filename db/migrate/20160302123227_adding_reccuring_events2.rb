class AddingReccuringEvents2 < ActiveRecord::Migration
  def change
    create_table :event_recurrences do |t|
      t.integer :event_id
      t.integer :month
      t.integer :day
      t.integer :week
    end
    add_foreign_key :event_recurrences, :events

    create_table :event_cancellations do |t|
      t.integer :event_id
      t.date :date
    end
    add_foreign_key :event_cancellations, :events

    create_table :calendars_events do |t|
      t.integer :calendar_id, null: false
      t.integer :event_id, null: false
    end

    add_index :calendars_events, [:calendar_id, :event_id], unique: true, name: 'calendars_events_main_key'
    add_index :calendars_events, :event_id
    add_foreign_key :calendars_events, :events
    add_foreign_key :calendars_events, :calendars

    create_table :events_documents do |t|
      t.integer :event_id
      t.integer :document_id
    end

    add_index :events_documents, [:event_id, :document_id], unique: true, name: 'events_documents_main_key'
    add_index :events_documents, :document_id

    reversible do |dir|
      dir.up do
        drop_table :calendar_items_calendars
        drop_table :calendar_items_documents
      end
      dir.down do
        create_table :calendar_items_calendars do |t|
          t.integer :calendar_id, null: false
          t.integer :calendar_item_id, null: false
        end

        add_index :calendar_items_calendars, [:calendar_id, :calendar_item_id], unique: true, name: 'calendars_calendar_items_main_key'
        add_index :calendar_items_calendars, :calendar_item_id

        create_table :calendar_items_documents do |t|
          t.integer :calendar_item_id
          t.integer :document_id
        end

        add_index :calendar_items_documents, [:calendar_item_id, :document_id], unique: true, name: 'calendar_items_documents_main_key'
        add_index :calendar_items_documents, :document_id
      end
    end
  end
end
