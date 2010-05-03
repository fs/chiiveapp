class AddGroupAndPostCounters < ActiveRecord::Migration
  def self.up
    add_column :groups, :posts_count, :integer, :default => 0
    add_column :users, :groups_count, :integer, :default => 0
  end

  def self.down
    remove_column :groups, :posts_count
    remove_column :users, :groups_count
  end
end
