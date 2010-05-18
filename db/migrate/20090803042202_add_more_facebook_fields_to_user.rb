class AddMoreFacebookFieldsToUser < ActiveRecord::Migration
  def self.up
    # used for matching up facebook users based on email, even if they have not connected their accounts
    add_column :users, :email_hash, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    
    add_index :users, :email_hash
    add_index :users, :facebook_uid
    add_index :users, :name
  end
  
  def self.down
    remove_index :users, :name
    remove_index :users, :facebook_uid
    remove_index :users, :email_hash
    
    remove_column :users, :last_name
    remove_column :users, :first_name
    remove_column :users, :email_hash
  end
end
