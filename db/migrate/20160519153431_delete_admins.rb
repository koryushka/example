class DeleteAdmins < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        drop_table :admins
      end
      dir.down do
        create_table 'admins', force: :cascade do |t|
          t.string 'email', default: '', null: false
          t.string 'encrypted_password', default: '', null: false
          t.string 'reset_password_token'
          t.datetime 'reset_password_sent_at'
          t.datetime 'remember_created_at'
          t.integer 'sign_in_count', default: 0, null: false
          t.datetime 'current_sign_in_at'
          t.datetime 'last_sign_in_at'
          t.inet 'current_sign_in_ip'
          t.inet 'last_sign_in_ip'
          t.integer 'failed_attempts', default: 0, null: false
          t.string 'unlock_token'
          t.datetime 'locked_at'
          t.datetime 'created_at', null: false
          t.datetime 'updated_at', null: false
          t.string 'provider', default: 'email', null: false
          t.string 'uid', default: '', null: false
          t.json 'tokens'
        end

        add_index 'admins', ['email'], name: 'index_admins_on_email', unique: true, using: :btree
        add_index 'admins', ['reset_password_token'], name: 'index_admins_on_reset_password_token', unique: true, using: :btree
        add_index 'admins', %w(uid provider), name: 'index_admins_on_uid_and_provider', unique: true, using: :btree
        add_index 'admins', ['unlock_token'], name: 'index_admins_on_unlock_token', unique: true, using: :btree
      end
    end
  end
end
