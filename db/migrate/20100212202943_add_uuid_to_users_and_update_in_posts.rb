class AddUuidToUsersAndUpdateInPosts < ActiveRecord::Migration
  def self.up
    add_column :users, :uuid, :string
    add_index :users, :uuid
    
    @users = User.find(:all)
    @users.each do |user|
      User.connection.execute("UPDATE users SET uuid=\"#{UUIDTools::UUID.timestamp_create().to_s.upcase}\" WHERE id=#{user.id}")
    end
    
    remove_index :posts, :upload_uid
    rename_column :posts, :upload_uid, :uuid
    add_index :posts, :uuid

    @posts = Post.find(:all, :conditions => 'uuid IS null')
    @posts.each do |post|
      Post.connection.execute("UPDATE posts SET uuid=\"#{UUIDTools::UUID.timestamp_create().to_s.upcase}\" WHERE id=#{post.id}")
    end
    
  end

  def self.down
    remove_index :posts, :uuid
    rename_column :posts, :uuid, :upload_uid
    add_index :posts, :upload_uid
    
    remove_index :users, :uuid
    remove_column :users, :uuid
  end
end
