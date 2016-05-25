class DeleteSharingPermissions < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        drop_table :sharing_permissions
      end
      dir.down do
        create_table 'sharing_permissions', force: :cascade do |t|
          t.string 'subject_class', null: false
          t.string 'action', default: "", null: false
          t.integer 'subject_id'
          t.integer 'user_id', null: false
        end

        add_index 'sharing_permissions', ['subject_id'], name: 'index_sharing_permissions_on_subject_id', using: :btree
        add_index 'sharing_permissions', ['user_id'], name: 'index_sharing_permissions_on_user_id', using: :btree
      end
    end
  end
end
