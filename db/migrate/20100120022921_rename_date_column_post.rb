class RenameDateColumnPost < ActiveRecord::Migration
  def self.up
    rename_column :posts, :date, :time_at
  end

  def self.down
    rename_column :posts, :time_at, :date
  end
end

