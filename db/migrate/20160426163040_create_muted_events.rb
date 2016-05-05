class CreateMutedEvents < ActiveRecord::Migration
  def change
    create_table :muted_events do |t|
      t.integer :event_id, null: false
      t.integer :user_id, null: false
      t.boolean :muted, null: false, default: false
      t.timestamps
    end

    add_index :muted_events, [:event_id, :user_id], unique: true
    add_index :muted_events, [:event_id, :muted]
    add_index :muted_events, :user_id
    add_index :muted_events, :upadted_at
  end
end
