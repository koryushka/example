class ChangeGoogleAccessTokensSyncronizableDefaultValue < ActiveRecord::Migration
  def change
    change_column :google_access_tokens, :synchronizable, :boolean, default: true
  end
end
