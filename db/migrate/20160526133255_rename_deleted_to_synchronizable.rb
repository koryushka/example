class RenameDeletedToSynchronizable < ActiveRecord::Migration
  def change
    rename_column :google_access_tokens, :deleted, :synchronizable
  end
end
