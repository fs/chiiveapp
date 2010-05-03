class CreateGroupOverlaps < ActiveRecord::Migration
  def self.up
    create_table :group_overlaps do |t|
      t.integer  :group_id,         :null => false
      t.integer  :overlapped_group_id,  :null => false
    end
    add_index :group_overlaps, :group_id
    add_index :group_overlaps, :overlapped_group_id
    # execute "ALTER TABLE `group_overlaps` ADD UNIQUE `group_id_overlapped_group_id` (`group_id`,`overlapped_group_id`)"
    
  end

  def self.down
    drop_table :group_overlaps
  end
end
