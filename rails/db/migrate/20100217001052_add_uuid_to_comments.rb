class AddUuidToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :uuid, :string
    add_index :comments, :uuid
    
    @comments = Comment.find(:all)
    @comments.each do |comment|
      Comment.connection.execute("UPDATE comments SET uuid=\"#{UUIDTools::UUID.timestamp_create().to_s.upcase}\" WHERE id=#{comment.id}")
    end
    
  end

  def self.down
    remove_index :comments, :uuid
    remove_column :comments, :uuid
  end
end
