class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :full
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.timestamps
    end
    add_index :addresses, :full
  end
  
  def self.down
    drop_table :addresses
  end
end