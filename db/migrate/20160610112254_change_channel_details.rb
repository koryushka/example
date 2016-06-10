class ChangeChannelDetails < ActiveRecord::Migration
  def change
    drop_table :google_channels

    create_table :google_channels do |t|
      t.string  :uuid
      t.integer :chennalable_id
      t.string  :google_resource_id
      t.string  :channelable_type
      t.timestamps null: false
    end

    add_index :google_channels, :chennalable_id

  end
end
