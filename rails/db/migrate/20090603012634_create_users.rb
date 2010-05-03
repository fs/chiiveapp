class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token,    :null => false
      t.string :single_access_token,  :null => false
      t.timestamps
    end
    add_index :users, :login
    add_index :users, :persistence_token
    add_index :users, :single_access_token
  end
  
  def self.down
    drop_table :users
  end
end
