class DeviseTokenAuthUpdateAdmins < ActiveRecord::Migration
  def change
    change_table(:admins) do |t|
      ## Required
      t.string :provider, :null => false, :default => 'email'
      t.string :uid, :null => false, :default => ''

      ## Tokens
      t.json :tokens
    end

    add_index :admins, [:uid, :provider],     :unique => true
  end
end
