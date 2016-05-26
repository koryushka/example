class AddDeletedToGoogleAccessTokens < ActiveRecord::Migration
  def change
    add_column :google_access_tokens, :deleted, :boolean
  end
end
