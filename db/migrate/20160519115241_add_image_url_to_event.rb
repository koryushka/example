class AddImageUrlToEvent < ActiveRecord::Migration
  def change
    add_column :events, :image_url, :string, null: true, limit: 2048
  end
end
