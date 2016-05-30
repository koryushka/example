class AddInvitationToken < ActiveRecord::Migration
  def change
    add_column :participations, :invitation_token, :string, null: true, limit: 256
    add_index :participations, :invitation_token
  end
end
