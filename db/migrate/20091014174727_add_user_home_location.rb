class AddUserHomeLocation < ActiveRecord::Migration
  def self.up
    add_column :users, :home_address_id, :integer
    add_column :users, :home_latitude, :decimal, :precision => 15, :scale => 10
    add_column :users, :home_longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :users, :home_address_id
    remove_column :users, :home_latitude
    remove_column :users, :home_longitude
  end
end
