class RenameTableGroupsToSets < ActiveRecord::Migration
  def self.up
    rename_table :groups, :personal_sets
    rename_column :posts, :group_id, :personal_set_id
    rename_column :users, :groups_count, :personal_sets_count
  end

  def self.down
    rename_table :personal_sets, :groups
    rename_column :posts, :personal_set_id, :group_id
    rename_column :users, :personal_sets_count, :groups_count
  end
end
