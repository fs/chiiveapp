class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :get_updates, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :subscribers
  end
end
