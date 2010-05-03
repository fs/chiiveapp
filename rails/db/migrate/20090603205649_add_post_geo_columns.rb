class AddPostGeoColumns < ActiveRecord::Migration
  def self.up
    add_column :posts, :latitude, :float, :precision => 15, :scale => 10
    add_column :posts, :longitude, :float, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :posts, :latitude
    remove_column :posts, :longitude
  end
end
