class CreateUploadedFiles < ActiveRecord::Migration
  def change
    create_table :uploaded_files do |t|
      t.string :path, null: false, limit: 2048
      t.timestamps null: false
    end

    add_column :documents, :file_id, :integer, null: false
    add_index :documents, :file_id
  end
end
