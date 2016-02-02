class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :title, null: false, limit: 128
      t.integer :user_id, null: false
      t.string :hex_color, null: false, default: '', limit: 6
      t.boolean :main, null: false, default: false
      t.integer :kind, null: false, default: 0
      t.boolean :visible, null: false, default: true
      t.timestamps
    end

    add_index :calendars, :user_id
    add_foreign_key :calendars, :users, :dependent => :cascade

    add_index :calendars, :kind
    add_index :calendars, :visible
  end
end
