class AddAddressPrecision < ActiveRecord::Migration
  def self.up
    add_column :addresses, :precision, :string
  end
  
  def self.down
    remove_column :addresses, :precision
  end
end
