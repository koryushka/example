class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.integer :user_id, null: true
      t.string :email, null: true, limit: 128
      t.integer :sender_id, null: false
      t.integer :participationable_id, null: false
      t.string :participationable_type, null: false, limit: 64
      t.integer :status, null: false, default: Participation::PENDING
      t.timestamps null: false
    end

    add_index :participations, :user_id
    add_foreign_key :participations, :users

    add_index :participations, :sender_id
    add_foreign_key :participations, :users, column: :sender_id

    add_index :participations, [:participationable_id, :participationable_type], name: 'index_polymorphic_participationable'
    add_index :participations, :status
  end
end
