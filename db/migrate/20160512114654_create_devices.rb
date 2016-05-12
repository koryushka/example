class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :device_token
      t.string :aws_endpoint_arn

      t.foreign_key :users
      t.timestamps null: false
    end
  end
end
