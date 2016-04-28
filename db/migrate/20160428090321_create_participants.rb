class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.integer :user_id, null: true
      t.integer :sender_id, null: false
      t.integer :iparticipantable_id, null: false
      t.string :participantable_type, null: false, limit: 64
      t.integer :status, null: false, default: Participant::PARTICIPATION_STATUS
      t.timestamps null: false
    end

    add_index :participants, :user_id
    add_foreign_key :participants, :users

    add_index :participants, :sender_id
    add_foreign_key :participants, :users, column: :sender_id

    add_index :participants, [:iparticipantable_id, :participantable_type]

    add_index :participants, :invitation_id
    add_foreign_key :participants, :invitations
  end
end
