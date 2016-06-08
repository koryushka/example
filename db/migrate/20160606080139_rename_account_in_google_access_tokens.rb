class RenameAccountInGoogleAccessTokens < ActiveRecord::Migration
  def change
    rename_column :google_access_tokens, :account, :account_name
  end
end
