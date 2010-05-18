class AddPostDate < ActiveRecord::Migration
  def self.up
    add_column :posts, :date, :datetime
    posts = Post.find(:all)
    posts.each do |post|
      post.date = post.created_at
      post.latitude = 0 if post.latitude.nil?
      post.longitude = 0 if post.longitude.nil?
      post.save!
    end
  end

  def self.down
    remove_column :posts, :date
  end
end
