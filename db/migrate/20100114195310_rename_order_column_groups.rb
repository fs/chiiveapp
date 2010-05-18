class RenameOrderColumnGroups < ActiveRecord::Migration
  def self.up
    rename_column :groups, :order, :order_index 
  end

  def self.down
    rename_column :groups, :order_index, :order
  end
end

