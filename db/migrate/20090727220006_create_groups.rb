class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :title
      t.string :description
      t.datetime :start
      t.datetime :finish
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.float :radius
      t.integer :address_id
      t.integer :user_id
      t.timestamps
    end
    add_index :groups, :title
    add_index :groups, :start
    add_index :groups, :finish
    add_index :groups, :latitude
    add_index :groups, :longitude
    add_index :groups, :radius
    
    add_column :posts, :group_id, :integer
    add_column :posts, :address_id, :integer
  end
  
  def self.down
    drop_table :groups
    
    remove_column :posts, :group_id
    remove_column :posts, :address_id
  end
end
