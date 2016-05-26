class AddRevokedToGoogleAccessTokens < ActiveRecord::Migration
  def change
    add_column :google_access_tokens, :revoked, :boolean, default: false
  end
end
