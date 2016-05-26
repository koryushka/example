class CreateGoogleAccessTokens < ActiveRecord::Migration
  def change
    create_table :google_access_tokens do |t|
      t.integer :user_id
      t.string :token
      t.date :expires_at
      t.string :account
      t.string :refresh_token

      t.timestamps null: false
    end
  end
end
