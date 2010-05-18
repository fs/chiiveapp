class AddPostUploadUid < ActiveRecord::Migration
  def self.up
    add_column :posts, :upload_uid, :string
    add_index :posts, :upload_uid
  end

  def self.down
    remove_column :posts, :upload_uid
  end
end
