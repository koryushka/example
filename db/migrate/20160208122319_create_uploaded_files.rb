class CreateUploadedFiles < ActiveRecord::Migration
  def change
    create_table :uploaded_files do |t|
      t.string :public_url, null: false, limit: 2048
      t.string :key, null: false, limit: 512
      t.timestamps null: false
    end

    add_column :documents, :uploaded_file_id, :integer, null: false
    add_index :documents, :uploaded_file_id
    add_foreign_key :documents, :uploaded_files
  end
end
