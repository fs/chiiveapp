class UpdatePostLatLngDatatype < ActiveRecord::Migration
  def self.up
    change_column :posts, :latitude, :decimal, :precision => 15, :scale => 10
    change_column :posts, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    change_column :posts, :latitude, :float
    change_column :posts, :longitude, :float
  end
end
