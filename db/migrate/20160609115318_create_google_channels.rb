class CreateGoogleChannels < ActiveRecord::Migration
  def change
    create_table :google_channels do |t|
      t.references :user, index: true, foreign_key: true
      t.string :uuid

      t.timestamps null: false
    end
  end
end
