class RenameDetailsInChannels < ActiveRecord::Migration
  def change
    rename_column :google_channels, :chennalable_id, :channelable_id
  end
end
