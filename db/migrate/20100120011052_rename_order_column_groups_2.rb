class RenameOrderColumnGroups2 < ActiveRecord::Migration
  def self.up
    rename_column :groups, :order_index, :order_social_set
  end

  def self.down
    rename_column :groups, :order_social_set, :order_index
  end
end

