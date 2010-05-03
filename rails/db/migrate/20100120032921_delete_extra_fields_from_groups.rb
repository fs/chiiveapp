class DeleteExtraFieldsFromGroups < ActiveRecord::Migration
  def self.up
    remove_index :groups, :start
    remove_index :groups, :finish
    remove_index :groups, :latitude
    remove_index :groups, :longitude
    remove_index :groups, :radius
    
    remove_column :groups, :start
    remove_column :groups, :finish
    remove_column :groups, :latitude
    remove_column :groups, :longitude
    remove_column :groups, :radius
    remove_column :groups, :address_id
  end

  def self.down
    add_column :groups, :start, :datetime
    add_column :groups, :finish, :datetime
    add_column :groups, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :groups, :longitude, :decimal, :precision => 15, :scale => 10
    add_column :groups, :radius, :float
    add_column :groups, :address_id, :integer
    
    add_index :groups, :start
    add_index :groups, :finish
    add_index :groups, :latitude
    add_index :groups, :longitude
    add_index :groups, :radius
  end
end

