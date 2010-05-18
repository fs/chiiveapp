class CreateSocialSets < ActiveRecord::Migration
  def self.up
    create_table :social_sets do |t|
      t.integer :order_count, :default => 0
      
      t.timestamps
    end
    
    add_column :groups, :social_set_id, :integer
    add_column :groups, :order, :integer
  end

  def self.down
    drop_table :social_sets
    
    remove_column :groups, :social_set_id
    remove_column :groups, :order
  end
end
