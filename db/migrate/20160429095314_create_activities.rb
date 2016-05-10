class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id, null: true
      t.integer :notificationable_id, null: false
      t.string :notificationable_type, null: false, limit: 64
      t.integer :activity_type, null: true, limit: 1

      t.timestamps null: false
    end

    add_index :activities, :user_id
    add_foreign_key :activities, :users

    add_index :activities, [:notificationable_id, :notificationable_type], name: 'index_polymorphic_notificationable'
    add_index :activities, [:notificationable_type, :activity_type]
  end
end
