class DeleteGroupOverlaps < ActiveRecord::Migration
  def self.up
    drop_table :group_overlaps
  end

  def self.down
    create_table "group_overlaps", :force => true do |t|
      t.integer "group_id",            :null => false
      t.integer "overlapped_group_id", :null => false
    end
  
    # add_index "group_overlaps", ["group_id", "overlapped_group_id"], :name => "group_id_overlapped_group_id", :unique => true
    add_index "group_overlaps", ["group_id"], :name => "index_group_overlaps_on_group_id"
    add_index "group_overlaps", ["overlapped_group_id"], :name => "index_group_overlaps_on_overlapped_group_id"
  end
end

