class AddFirstLastNameToProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :full_name, :string, limit: 64, default: '', null: false
    add_column :profiles, :first_name, :string, limit: 64, default: '', null: false
    add_column :profiles, :last_name, :string, limit: 64, default: '', null: false
    add_index :profiles, [:first_name, :last_name]
  end
end
