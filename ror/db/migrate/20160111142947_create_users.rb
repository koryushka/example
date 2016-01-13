class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name, :limit => 64
      t.string :password, :limit => 128
      t.string :email, :limit => 128
      t.timestamps null: false
    end
  end
end