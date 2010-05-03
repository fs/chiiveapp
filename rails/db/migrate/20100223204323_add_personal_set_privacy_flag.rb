class AddPersonalSetPrivacyFlag < ActiveRecord::Migration
  def self.up
    add_column :personal_sets, :public, :boolean, :default => false
  end

  def self.down
    remove_column :personal_sets, :public
  end
end
