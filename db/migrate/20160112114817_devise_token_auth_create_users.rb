class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      ## Required
      t.string :provider, :null => false, :default => 'email'
      t.string :uid, :null => false, :default => ''

      ## Tokens
      t.json :tokens
    end

    add_index :users, [:uid, :provider],     :unique => true
  end
end
