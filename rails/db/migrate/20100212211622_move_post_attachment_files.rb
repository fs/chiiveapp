class MovePostAttachmentFiles < ActiveRecord::Migration
  # With the new UUID system used for record retrieval from iphone and other remote sources
  # need to move all attachments of old posts into new UUID-based folder system
  def self.up
    @posts = Post.all
    @posts.each do |post|
      origin_path = "#{RAILS_ROOT}/public/system/photos/#{post.id}"
      destination_path = "#{RAILS_ROOT}/public/system/photos/#{post.uuid}"
      begin
        FileUtils.move(origin_path, destination_path)
      rescue
        puts "error from #{origin_path} to #{destination_path}"
      end
    end
  end

  def self.down
    @posts = Post.all
    @posts.each do |post|
      destination_path = "#{RAILS_ROOT}/public/system/photos/#{post.id}"
      origin_path = "#{RAILS_ROOT}/public/system/photos/#{post.uuid}"
      begin
        FileUtils.move(origin_path, destination_path)
      rescue
        puts "error from #{origin_path} to #{destination_path}"
      end
    end
  end
end
