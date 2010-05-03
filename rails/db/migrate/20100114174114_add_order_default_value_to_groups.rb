class AddOrderDefaultValueToGroups < ActiveRecord::Migration
  def self.up
    change_column :groups, :order, :integer, :default => 0 
  end

  def self.down
  end
end
