class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :device_token
      t.string :aws_endpoint_arn

      t.timestamps null: false
    end
    add_index :devices, :user_id
    add_foreign_key :devices, :users, :dependent => :cascade
  end
end
