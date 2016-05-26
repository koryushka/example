class ChangeGoogleTokenExpiresInType < ActiveRecord::Migration
  def change
    change_column :google_access_tokens, :expires_at, :datetime
  end
end
