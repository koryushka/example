class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title, null: false, limit: 128
      t.string :notes, null: false, default: '', limit: 2048
      t.string :remote_url, null: false, default: '', limit: 2048
      t.string :tags, null: false, default: '', limit: 2048
      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_index :documents, :user_id
    add_foreign_key :documents, :users

    create_table :calendar_items_documents do |t|
      t.integer :calendar_item_id
      t.integer :document_id
    end

    add_index :calendar_items_documents, [:calendar_item_id, :document_id], unique: true, name: 'calendar_items_documents_main_key'
    add_index :calendar_items_documents, :document_id
  end
end
