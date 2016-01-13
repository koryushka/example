class RemovePasswordDigest < ActiveRecord::Migration
  def change
    remove_column :users, :password_digest, :string, limit: 128
  end
end
